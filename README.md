# Terraform deployment of Miggo for ECS

This Terraform module deploys Miggo Collector and Miggo Operator for ECS, based on the lambda function.


## Architecture

The is the module architecture:

<img src="https://github.com/miggo-io/terraform-aws-miggo-deployment/blob/main/imges/ECS_Terraform_Deployment.jpg?raw=true" width="900">

Network architecture (default deployment):

<img src="https://github.com/miggo-io/terraform-aws-miggo-deployment/blob/main/imges/ECS_Terraform_Deployment_Network.jpg?raw=true" width="900">


## Usage

1. Install terraform [Hashicorp Ref.](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. AWS CLI installation  [AWS Ref.](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. AWS CLI authentication [AWS Ref.](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
4. Create a `provider.tf` file [Terrform Ref.](https://www.terraform.io/language/providers/configuration)
5. Create a `main.tf` and configure the module inputs. Here are [Miggo examples](https://github.com/miggo-io/terraform-aws-miggo-deployment/tree/main/examples)
6. Create a secret with the following keys (Provided by Miggo):
```
collector_auth: ...
lambda_auth: ...
```
7. run the following commands:
```sh
terraform init
terraform apply
```
