
resource "aws_iam_role" "task_exec_role" {
  count = var.custom_iam_task_exec_role_arn == "" ? 1 : 0

  name                = "${var.environment}-task-exec"
  managed_policy_arns = [aws_iam_policy.task_exec_role[0].arn,aws_iam_policy.dockerhub_secret[0].arn]
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

resource "aws_iam_policy" "task_exec_role" {
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
          "kms:Decrypt",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.region}:${data.aws_caller_identity.current.account_id}:secret:${var.dockerhub_secret_name}",
          "arn:aws:kms:${local.region}:${data.aws_caller_identity.current.account_id}:key/*"
        ]
      }
    ]
  })
}