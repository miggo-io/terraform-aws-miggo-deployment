
resource "aws_alb" "collector" {
  name               = "${var.environment}-collector-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_collector.id]
  subnets            = var.create_vpc ? module.vpc[0].public_subnets : var.vpc_public_subnets
  tags               = local.tags
}

resource "aws_lb_target_group" "collector" {

  name        = local.collector_settings.container_name
  port        = local.collector_settings.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}


resource "aws_lb_listener" "collector" {
  count = var.deploy_collector ? 1 : 0

  load_balancer_arn = aws_alb.collector[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.collector[0].arn
  }
}

resource "aws_security_group" "alb_collector" {
  count = var.deploy_collector ? 1 : 0

  name        = "${local.collector_settings.container_name}-alb"
  description = "Allow inbound/outbound traffic for Miggo collector"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  ingress {
    description = "Inbound from NAT to collector's ALB HTTP"
    from_port   = 443
    to_port     = 4318
    protocol    = "tcp"
    cidr_blocks = var.collector_sg_ingress_cidr_blocks
  }
  ingress {
    description = "Inbound from NAT to collector's ALB GRPC"
    from_port   = 4443
    to_port     = 4317
    protocol    = "tcp"
    cidr_blocks = var.collector_sg_ingress_cidr_blocks
  }
  egress {
    description      = "Outbound all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
