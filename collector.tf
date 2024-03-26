
locals {
  collector_settings = {
    container_name      = "${var.environment}-collector"
    task_cpu            = var.collector_resource.cpu
    task_memory         = var.collector_resource.memory
    container_cpu       = var.collector_resource.cpu
    container_memory    = var.collector_resource.memory
    container_port_http = 4318
    container_port_grpc = 4317
  }

  collector_definition = templatefile(("${path.module}/templates/collector_task_def.tpl"), {
    name                 = local.collector_settings.container_name
    cpu                  = local.collector_settings.container_cpu
    memory               = local.collector_settings.container_memory
    port_http            = local.collector_settings.container_port_http
    port_grpc            = local.collector_settings.container_port_grpc
    log_group            = try(aws_cloudwatch_log_group.miggo.name, "")
    log_stream           = try(aws_cloudwatch_log_stream.collector_log_stream[0].name, "")
    aws_region           = local.region
    additional_env_vars  = var.additional_collector_env_vars
    environment          = var.environment
    dockerhub_secret_arn = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:secret:${var.dockerhub_secret_name}"
    miggo_secret         = try(sensitive(jsondecode(data.aws_secretsmanager_secret_version.miggo[0].secret_string)["MIGGO_OTEL_AUTH"]), "")
    collector_image      = var.collector_image
    collector_version    = var.collector_version
    miggo_endpoint       = var.miggo_endpoint
  })

}


resource "aws_ecs_task_definition" "collector" {
  count = var.deploy_collector ? 1 : 0

  family                   = local.collector_settings.container_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.collector_settings.task_cpu
  memory                   = local.collector_settings.task_memory
  execution_role_arn       = aws_iam_role.task_exec_role[0].arn
  task_role_arn            = aws_iam_role.task_exec_role[0].arn
  container_definitions    = local.collector_definition

  volume {
    name = "otel-config"
  }

}

resource "aws_ecs_service" "collector" {
  count = var.deploy_collector ? 1 : 0

  name            = local.collector_settings.container_name
  cluster         = var.create_cluster ? aws_ecs_cluster.miggo[0].id : data.aws_ecs_cluster.provided[0].id
  task_definition = aws_ecs_task_definition.collector[0].arn
  desired_count   = var.collector_replicas
  launch_type     = "FARGATE"
  # launch_type     = var.fargate ? "FARGATE" : null
  network_configuration {
    security_groups = [aws_security_group.collector[0].id]
    subnets         = var.create_vpc ? module.vpc[0].private_subnets : var.vpc_private_subnets
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.collector_http[0].arn
    container_name   = local.collector_settings.container_name
    container_port   = local.collector_settings.container_port_http
  }
  # load_balancer {
  #   target_group_arn = aws_lb_target_group.collector_grpc[0].arn
  #   container_name   = local.collector_settings.container_name
  #   container_port   = local.collector_settings.container_port_grpc
  # }

  # dynamic "capacity_provider_strategy" {
  #   for_each = var.fargate ? [1] : [0]
  #   content {
  #     capacity_provider = aws_ecs_capacity_provider.main[0].name
  #     base              = 1
  #     weight            = 100
  #   }
  # }

}


resource "aws_cloudwatch_log_stream" "collector_log_stream" {
  count = var.deploy_collector ? 1 : 0

  name           = "${var.environment}-collector"
  log_group_name = aws_cloudwatch_log_group.miggo.name
}


resource "aws_security_group" "collector" {
  count = var.deploy_collector ? 1 : 0

  name        = local.collector_settings.container_name
  description = "Allow inbound/outbound traffic for Miggo collector"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  ingress {
    description = "Inbound from ALB to collector for http"
    from_port   = local.collector_settings.container_port_http
    to_port     = local.collector_settings.container_port_http
    protocol    = "tcp"
    cidr_blocks = var.collector_sg_ingress_cidr_blocks
  }
  # ingress {
  #   description = "Inbound from ALB to collector for grpc"
  #   from_port   = local.collector_settings.container_port_grpc
  #   to_port     = local.collector_settings.container_port_grpc
  #   protocol    = "tcp"
  #   cidr_blocks = var.collector_sg_ingress_cidr_blocks
  # }
  ingress {
    description = "Health check for oTel"
    from_port   = 13133
    to_port     = 13133
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