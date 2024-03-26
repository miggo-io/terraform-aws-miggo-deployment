data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region       = var.region == "" ? data.aws_region.current.name : var.region
  cluster_name = var.cluster_name == "" ? "${var.environment}-ecs-cluster" : var.cluster_name
  tags = {
    terraform   = true
    Environment = var.environment
    Service     = "Miggo"
  }
}
resource "aws_ecs_cluster" "miggo" {
  count = var.create_cluster ? 1 : 0

  name = local.cluster_name
  tags = local.tags
}

data "aws_ecs_cluster" "provided" {
  count = var.create_cluster ? 0 : 1

  cluster_name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "miggo" {
  name_prefix = var.environment
}


# --- ECS Node SG ---

resource "aws_security_group" "ecs_node_sg" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  name_prefix = "demo-ecs-node-sg-"
  vpc_id      = module.vpc[0].vpc_id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- ECS Node Role ---

data "aws_iam_policy_document" "ecs_node_doc" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_node_role" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  name_prefix        = "${var.environment}-ecs-node-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_doc[0].json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  role       = aws_iam_role.ecs_node_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  name_prefix = "${var.environment}-ecs-node-profile"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role[0].name
}

# --- ECS Launch Template ---

data "aws_ami" "amzn" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_launch_template" "ecs_ec2" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  name_prefix            = "${var.environment}-ecs-ec2-"
  image_id               = data.aws_ami.amzn[0].image_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ecs_node_sg[0].id]

  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node[0].arn }
  monitoring { enabled = true }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      set -eux
      echo "ECS_CLUSTER=${aws_ecs_cluster.miggo[0].name}" >> /etc/ecs/ecs.config
    EOF
  )
}

# --- ECS ASG ---

resource "aws_autoscaling_group" "ecs" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  name_prefix               = "${var.environment}-ecs-asg-"
  vpc_zone_identifier       = module.vpc[0].private_subnets
  min_size                  = 1
  max_size                  = 4
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs_ec2[0].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-ecs-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

# --- ECS Capacity Provider ---

resource "aws_ecs_capacity_provider" "main" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  name = "${var.environment}-ecs-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs[0].arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  count = var.create_cluster && !var.fargate ? 1 : 0

  cluster_name       = aws_ecs_cluster.miggo[0].name
  capacity_providers = [aws_ecs_capacity_provider.main[0].name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main[0].name
    base              = 1
    weight            = 100
  }
}