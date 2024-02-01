module "lambda_function" {
  count = var.deploy_ecs_operator ? 1 : 0

  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.1"

  function_name = "${var.environment}-ecs-operator"
  description   = "Miggo ECS Operator"
  handler       = "main.handler"
  runtime       = "nodejs18.x"
  memory_size   = 256

  s3_existing_package = {
    bucket     = try(var.ecs_operator_s3.bucket, null)
    key        = try(var.ecs_operator_s3.key, null)
    version_id = try(var.ecs_operator_s3.version_id, null)
  }
  environment_variables = {
    ECS_CLUSTER_NAME = local.cluster_name
    MIGGO_CONFIG_ARN = "s3://${try(var.ecs_operator_s3.bucket, null)}/${var.tenant_id}/lambda/config.json"
    # MIGGO_LOGGING_ROLE_ARN = ""
    # MIGGO_ROLE_EXTERNAL_ID = ""
    # SENTRY_DSN = ""
    # MIGGO_REMOTE_LOG_GROUP = ""
  }

  tags = local.tags
}