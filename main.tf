data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region = var.region == "" ? data.aws_region.current.name : var.region
  cluster_name = var.create_cluster ? "${var.environment}-ecs-cluster" : var.cluster_name
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