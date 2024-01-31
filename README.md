# Terraform deployment of Miggo for ECS

This Terraform module deploys Miggo Collector and Miggo Operator for ECS, based on the lambda function.


## Architecture

The is the module architecture:

<img src="https://github.com/miggo-io/terraform-aws-miggo-deployment/blob/main/imges/ECS_Terraform_Deployment.jpg?raw=true" width="900">

Network architecture (default deployment):

<img src="https://github.com/miggo-io/terraform-aws-miggo-deployment/blob/main/imges/ECS_Terraform_Deployment_Network.jpg?raw=true" width="900">


## Usage

1. Install terraform [Ref.](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. AWS CLI instaltion  [Ref.](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. AWS CLI authentication [Ref.](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
4. Create a `provider.tf` file [Ref.](https://www.terraform.io/language/providers/configuration).
5. Create a `main.tf` and configure the module inputs, here is [examples](https://github.com/miggo-io/terraform-aws-miggo-deployment/tree/main/examples)
6. Create a secret in AWS Secret Manager with the following keys (Valyes provided by Miggo):
```
collector_auth: ...
lambda_auth: ...
dockerhub_secret: ...
```
7. Run the following commands:
```sh
terraform init
terraform apply
```
