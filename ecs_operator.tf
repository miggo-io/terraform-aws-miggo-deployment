# module "lambda_function" {
#   count = var.deploy_ecs_operator ? 1 : 0

#   source  = "terraform-aws-modules/lambda/aws"
#   version = "7.2.1"

#   function_name = "${var.environment}-ecs-operator"
#   description   = "Miggo ECS Operator"
#   handler       = "main.handler"
#   runtime       = "nodejs18.x"
#   memory_size   = 256

  # s3_existing_package = {
  #   bucket     = try(var.ecs_operator_s3.bucket, null)
  #   key        = try(var.ecs_operator_s3.key, null)
  #   version_id = try(var.ecs_operator_s3.version_id, null)
  # }
#   environment_variables = {
#     ECS_CLUSTER_NAME = local.cluster_name
#     MIGGO_CONFIG_ARN = "s3://${try(var.ecs_operator_s3.bucket, null)}/${var.tenant_id}/lambda/config.json"
#     # MIGGO_LOGGING_ROLE_ARN = ""
#     # MIGGO_ROLE_EXTERNAL_ID = ""
#     # SENTRY_DSN = ""
#     # MIGGO_REMOTE_LOG_GROUP = ""
#   }

#   tags = local.tags
# }

resource "aws_iam_role" "LambdaExecutionRole" {
  name               = "LambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

resource "aws_lambda_function" "LambdaFunction" {
  count = var.deploy_ecs_operator ? 1 : 0

  function_name    = "${var.environment}-ecs-operator"
  role             = aws_iam_role.LambdaExecutionRole.arn
  handler          = "main.handler"
  runtime          = "nodejs18.x"
  memory_size      = 256

  s3_bucket = try(var.ecs_operator_s3.bucket, null)
  s3_key        = try(var.ecs_operator_s3.key, null)
  s3_object_version = try(var.ecs_operator_s3.version_id, null)

  environment {
    variables = {
      ECS_CLUSTER_NAME       = local.cluster_name
      MIGGO_CONFIG_ARN = "s3://${try(var.ecs_operator_s3.bucket, null)}/${var.tenant_id}/lambda/config.json"
      # MIGGO_LOGGING_ROLE_ARN = ""
      # MIGGO_ROLE_EXTERNAL_ID = ""
      # SENTRY_DSN             = ""
      # MIGGO_REMOTE_LOG_GROUP = ""
    }
  }
}