data "aws_route53_zone" "selected" {

  name         = var.domain_name
  private_zone = var.public ? false : true
}

resource "aws_route53_zone" "sub_domain" {
  count = var.create_vpc ? 1 : 0

  name    = "${var.environment}.${var.domain_name}"
  comment = "${var.environment}.${var.domain_name}"

  dynamic "vpc" {
    for_each = var.public ? [] : [1]
    content {
      vpc_id = module.vpc[0].vpc_id
    }
  }
}

resource "aws_route53_record" "sub_domain" {
  count = var.create_vpc ? 1 : 0

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.selected.zone_id
  name            = "${var.environment}.${data.aws_route53_zone.selected.name}"
  type            = "NS"
  ttl             = "172800"
  records         = aws_route53_zone.sub_domain[0].name_servers
}

resource "aws_route53_record" "collector" {
  count      = var.deploy_collector ? 1 : 0
  depends_on = [module.acm]

  zone_id = var.create_vpc ? aws_route53_zone.sub_domain[0].id : data.aws_route53_zone.selected.id
  name    = "collector.${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.collector[0].dns_name
    zone_id                = aws_alb.collector[0].zone_id
    evaluate_target_health = true
  }
}

module "acm" {
  count = var.certificate_arn == "" && var.deploy_collector || var.deploy_demo_app ? 1 : 0

  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "collector.${var.environment}.${var.domain_name}"
  zone_id     = var.create_vpc ? aws_route53_zone.sub_domain[0].id : data.aws_route53_zone.selected.id

  subject_alternative_names = [
    "demo.${var.environment}.${var.domain_name}",
  ]

  wait_for_validation = true
  tags                = local.tags
}

### Demo application

resource "aws_route53_record" "demo" {
  count      = var.deploy_demo_app ? 1 : 0
  depends_on = [module.acm]

  zone_id = var.create_vpc ? aws_route53_zone.sub_domain[0].id : data.aws_route53_zone.selected.id
  name    = "demo.${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.demo[0].dns_name
    zone_id                = aws_alb.demo[0].zone_id
    evaluate_target_health = true
  }
}
