
resource "aws_alb" "collector" {
  count = var.deploy_collector ? 1 : 0

  name               = "${var.environment}-collector-alb"
  internal           = var.public ? false : true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_collector[0].id]
  subnets            = var.create_vpc ? module.vpc[0].public_subnets : var.vpc_public_subnets
  tags               = local.tags
}

resource "aws_lb_target_group" "collector_http" {
  count = var.deploy_collector ? 1 : 0

  name        = "${local.collector_settings.container_name}-http"
  port        = local.collector_settings.container_port_http
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  health_check {
    port     = 13133
    protocol = "HTTP"
    path     = "/"
  }
}

# resource "aws_lb_target_group" "collector_grpc" {
#   count = var.deploy_collector ? 1 : 0

#   name        = "${local.collector_settings.container_name}-grpc"
#   port        = local.collector_settings.container_port_grpc
#   protocol    = "HTTP"
#   protocol_version = "GRPC"
#   target_type = "ip"
#   vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
#   health_check {
#     protocol = "HTTP"
#     path     = "/"
#   }
# }


resource "aws_lb_listener" "collector_http" {
  count = var.deploy_collector ? 1 : 0

  load_balancer_arn = aws_alb.collector[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn == "" ? module.acm[0].acm_certificate_arn : var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.collector_http[0].arn
  }
}

# resource "aws_lb_listener" "collector_grpc" {
#   count = var.deploy_collector ? 1 : 0

#   load_balancer_arn = aws_alb.collector[0].arn
#   port              = 4317
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn == "" ? module.acm[0].acm_certificate_arn : var.certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.collector_grpc[0].arn
#   }
# }


resource "aws_security_group" "alb_collector" {
  count = var.deploy_collector ? 1 : 0

  name        = "${local.collector_settings.container_name}-alb"
  description = "Allow inbound/outbound traffic for Miggo collector"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  ingress {
    description = "Inbound from NAT to collector ALB HTTP"
    from_port   = 443
    to_port     = local.collector_settings.container_port_http
    protocol    = "tcp"
    cidr_blocks = var.collector_sg_ingress_cidr_blocks
  }
  # ingress {
  #   description = "Inbound from NAT to collector ALB GRPC"
  #   from_port   = 4317
  #   to_port     = local.collector_settings.container_port_grpc
  #   protocol    = "tcp"
  #   cidr_blocks = var.collector_sg_ingress_cidr_blocks
  # }
  egress {
    description      = "Outbound all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}



#### DEMO application



resource "aws_alb" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  name               = "${var.environment}-demo-alb"
  internal           = var.public ? false : true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_demo[0].id]
  subnets            = var.create_vpc ? module.vpc[0].public_subnets : var.vpc_public_subnets
  tags               = local.tags
}

resource "aws_lb_target_group" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  name        = local.demo_settings.container_name
  port        = local.demo_settings.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}


resource "aws_lb_listener" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  load_balancer_arn = aws_alb.demo[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn == "" ? module.acm[0].acm_certificate_arn : var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo[0].arn
  }
}

resource "aws_security_group" "alb_demo" {
  count = var.deploy_demo_app ? 1 : 0

  name        = "${local.demo_settings.container_name}-alb"
  description = "Allow inbound/outbound traffic for Miggo demo"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  ingress {
    description = "Inbound from NAT to demo ALB HTTP"
    from_port   = 443
    to_port     = local.demo_settings.container_port
    protocol    = "tcp"
    cidr_blocks = var.demo_sg_ingress_cidr_blocks
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
