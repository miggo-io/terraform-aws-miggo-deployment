data "aws_secretsmanager_secret" "miggo" {
  count = var.deploy_collector ? 1 : 0

  name = var.miggo_secret_name
}

data "aws_secretsmanager_secret_version" "miggo" {
  count = var.deploy_collector ? 1 : 0

  secret_id = data.aws_secretsmanager_secret.miggo[0].id
}

data "aws_secretsmanager_secret" "dockerhub" {
  count = var.deploy_collector ? 1 : 0

  name = var.dockerhub_secret_name
}