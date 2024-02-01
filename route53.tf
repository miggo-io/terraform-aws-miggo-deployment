data "aws_route53_zone" "selected" {
  count = var.deploy_collector ? 1 : 0

  name         = var.domain_name
  private_zone = true
}

resource "aws_route53_record" "collector" {
  count = var.deploy_collector ? 1 : 0

  zone_id = aws_route53_zone.selected[0].id
  name    = "${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.collector[0].dns_name
    zone_id                = aws_alb.collector[0].zone_id
    evaluate_target_health = true
  }
}

module "acm" {
  count = var.certificate_arn == "" && var.deploy_collector ? 1 : 0

  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "${var.environment}.${var.domain_name}"
  zone_id     = aws_route53_zone.selected[0].zone_id

  wait_for_validation = true
  tags                = local.tags
}

