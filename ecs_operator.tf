resource "aws_lambda_function" "LambdaFunction" {
  count = var.deploy_ecs_operator ? 1 : 0

  function_name = "${var.environment}-ecs-operator"
  role          = aws_iam_role.lambda_exec_role[0].arn
  handler       = "main.handler"
  runtime       = "nodejs18.x"
  memory_size   = 256

  s3_bucket         = try(var.ecs_operator_s3.bucket, null)
  s3_key            = try(var.ecs_operator_s3.key, null)
  s3_object_version = try(var.ecs_operator_s3.version, null)

  logging_config {
    log_format = "Text"
  }

  environment {
    variables = {
      ECS_CLUSTER_NAME           = local.cluster_name
      MIGGO_CONFIG_ARN           = "s3://${try(var.ecs_operator_s3.bucket, null)}/${var.tenant_id}/lambda/config.json"
      TENANT_ID                  = var.tenant_id
      MIGGO_INFRA_AGENT_ENDPOINT = aws_route53_record.collector[0].fqdn
      # MIGGO_LOGGING_ROLE_ARN = ""
      # MIGGO_ROLE_EXTERNAL_ID = ""
      # SENTRY_DSN             = ""
      # MIGGO_REMOTE_LOG_GROUP = ""
    }
  }
}

resource "aws_cloudwatch_log_stream" "ecs_operator" {
  count = var.deploy_ecs_operator ? 1 : 0

  name           = "${var.environment}-ecs-operator"
  log_group_name = aws_cloudwatch_log_group.miggo.name
}