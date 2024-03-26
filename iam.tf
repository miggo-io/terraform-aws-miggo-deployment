
resource "aws_iam_role" "task_exec_role" {
  count = var.custom_iam_task_exec_role_arn == "" ? 1 : 0

  name = "${var.environment}-task-exec"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.task_exec_policy[0].arn,
    aws_iam_policy.dockerhub_secret[0].arn,
  ]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Sid    = "1"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "task_exec_policy" {
  count = var.custom_iam_task_exec_role_arn == "" ? 1 : 0

  name = "${var.environment}-task-logs"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*"]
      }
    ]
  })
}

resource "aws_iam_policy" "dockerhub_secret" {
  count = var.custom_iam_task_exec_role_arn == "" ? 1 : 0

  name = "${var.environment}-task-get-dockerhub-secret"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:*",
        ]
      },
    ]
  })
}


## lambda

resource "aws_iam_role" "lambda_exec_role" {
  count = var.deploy_ecs_operator ? 1 : 0

  name = "${var.environment}-ecs-operator-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.lambda_logs_policy[0].arn,
    aws_iam_policy.lambda_extra_policy[0].arn
  ]
}

resource "aws_iam_policy" "lambda_logs_policy" {
  count = var.deploy_ecs_operator ? 1 : 0

  name = "${var.environment}-ecs-operator-logs"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*"]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_extra_policy" {
  count = var.deploy_ecs_operator ? 1 : 0

  name = "${var.environment}-ecs-operator-extra"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = ["arn:aws:s3:::${try(var.ecs_operator_s3.bucket, "*")}/${var.tenant_id}/lambda/config.json"]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = ["arn:aws:iam::${data.aws_caller_identity.current.id}:role/${var.environment}-task-exec"]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService"
        ]
        Resource = ["arn:aws:ecs:${local.region}:${data.aws_caller_identity.current.id}:service/${local.cluster_name}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = ["*"]
      }
    ]
  })
}