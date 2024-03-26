
locals {
  demo_settings = {
    container_name   = "${var.environment}-demo"
    task_cpu         = "256"
    task_memory      = "512"
    container_cpu    = "256"
    container_memory = "512"
    container_port   = 2368
  }

  demo_definition = templatefile(("${path.module}/templates/demo_task_def.tpl"), {
    name                 = local.demo_settings.container_name
    cpu                  = local.demo_settings.container_cpu
    memory               = local.demo_settings.container_memory
    port                 = local.demo_settings.container_port
    log_group            = try(aws_cloudwatch_log_group.miggo.name, "")
    log_stream           = try(aws_cloudwatch_log_stream.demo_log_stream[0].name, "")
    aws_region           = local.region
    environment          = var.environment
    dockerhub_secret_arn = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:secret:${var.dockerhub_secret_name}"
  })

}


resource "aws_ecs_task_definition" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  family                   = local.demo_settings.container_name
  requires_compatibilities = var.fargate ? ["FARGATE"] : ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = local.demo_settings.task_cpu
  memory                   = local.demo_settings.task_memory
  execution_role_arn       = aws_iam_role.task_exec_role[0].arn
  task_role_arn            = aws_iam_role.task_exec_role[0].arn
  container_definitions    = local.demo_definition

}

resource "aws_ecs_service" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  name            = local.demo_settings.container_name
  cluster         = var.create_cluster ? aws_ecs_cluster.miggo[0].id : data.aws_ecs_cluster.provided[0].id
  task_definition = aws_ecs_task_definition.demo[0].arn
  desired_count   = 1
  launch_type     = var.fargate ? "FARGATE" : null
  network_configuration {
    security_groups = [aws_security_group.demo[0].id]
    subnets         = var.create_vpc ? module.vpc[0].private_subnets : var.vpc_private_subnets
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.demo[0].arn
    container_name   = local.demo_settings.container_name
    container_port   = local.demo_settings.container_port
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.fargate ? [1] : [0]
    content {
      capacity_provider = aws_ecs_capacity_provider.main[0].name
      base              = 1
      weight            = 100
    }
  }

}


resource "aws_cloudwatch_log_stream" "demo_log_stream" {
  count = var.deploy_demo_app ? 1 : 0

  name           = "${var.environment}-demo"
  log_group_name = aws_cloudwatch_log_group.miggo.name
}


resource "aws_security_group" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  name        = local.demo_settings.container_name
  description = "Allow inbound/outbound traffic for Miggo demo"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  ingress {
    description = "Inbound from ALB to demo for http"
    from_port   = local.demo_settings.container_port
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