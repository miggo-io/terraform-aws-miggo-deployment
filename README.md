# Terraform deployment of Miggo for ECS

This Terraform module deploys Miggo Collector and Miggo Operator for ECS, based on the lambda function.


## Architecture

The is the module architecture:

<img src="https://github.com/miggo-io/terraform-aws-miggo-deployment/blob/main/images/ECS_Terraform_Deployment.jpg?raw=true" width="900">

Network architecture (default deployment):

<img src="https://github.com/miggo-io/terraform-aws-miggo-deployment/blob/main/images/ECS_Terraform_Deployment_Network.jpg?raw=true" width="900">


## Usage

1. Install terraform [Hashicorp Ref.](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. AWS CLI installation  [AWS Ref.](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. AWS CLI authentication [AWS Ref.](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
4. Create a `provider.tf` file [Terraform Ref.](https://www.terraform.io/language/providers/configuration)
5. Create a `main.tf` and configure the module inputs. Here are [Miggo examples](https://github.com/miggo-io/terraform-aws-miggo-deployment/tree/main/examples)
6. Create a two secrets in AWS Secret Manager. 
First for dockerhub with the following keys (Values provided by Miggo): 
```sh
aws secretsmanager create-secret --name miggo_dockerhub --secret-string {\"PASSWORD\":\"PASSWORDVALUE\", \"USERNAME\":\"USERNAMEVALUE\"}
```
The second with the following keys (Values provided by Miggo):
```sh
aws secretsmanager create-secret --name miggo --secret-string {\"MIGGO_OTEL_AUTH\":\"PASSWORDVALUE\", \"LAMBDA_AUTH\":\"PASSWORDVALUE\"}
```
7. Run the following commands:
```sh
terraform init
terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.41.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 4.0.2 |

## Resources

| Name | Type |
|------|------|
| [aws_alb.collector](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/alb) | resource |
| [aws_alb.demo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/alb) | resource |
| [aws_autoscaling_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.miggo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.collector_log_stream](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.demo_log_stream](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.ecs_operator](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/cloudwatch_log_stream) | resource |
| [aws_ecs_capacity_provider.main](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.miggo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.main](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.collector](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/ecs_service) | resource |
| [aws_ecs_service.demo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.collector](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.demo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/ecs_task_definition) | resource |
| [aws_iam_instance_profile.ecs_node](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.dockerhub_secret](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_extra_policy](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.task_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_node_role](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/iam_role) | resource |
| [aws_iam_role.task_exec_role](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_node_role_policy](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.LambdaFunction](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/lambda_function) | resource |
| [aws_launch_template.ecs_ec2](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/launch_template) | resource |
| [aws_lb_listener.collector_http](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/lb_listener) | resource |
| [aws_lb_listener.demo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.collector_http](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.demo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/lb_target_group) | resource |
| [aws_route53_record.collector](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/route53_record) | resource |
| [aws_route53_record.demo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/route53_record) | resource |
| [aws_route53_record.sub_domain](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/route53_record) | resource |
| [aws_route53_zone.sub_domain](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/route53_zone) | resource |
| [aws_security_group.alb_collector](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/security_group) | resource |
| [aws_security_group.alb_demo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/security_group) | resource |
| [aws_security_group.collector](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/security_group) | resource |
| [aws_security_group.demo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/security_group) | resource |
| [aws_security_group.ecs_node_sg](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/resources/security_group) | resource |
| [aws_ami.amzn](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/data-sources/caller_identity) | data source |
| [aws_ecs_cluster.provided](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/data-sources/ecs_cluster) | data source |
| [aws_iam_policy_document.ecs_node_doc](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/data-sources/region) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/data-sources/route53_zone) | data source |
| [aws_secretsmanager_secret.dockerhub](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.miggo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.miggo](https://registry.terraform.io/providers/hashicorp/aws/5.41.0/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_collector_env_vars"></a> [additional\_collector\_env\_vars](#input\_additional\_collector\_env\_vars) | Additional env variables of contorller, configure as map of key=values | `any` | `{}` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of a certificate for Miggo collecotr, Will be used by ALB | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ECS cluster name, if we want to deploy to existing one or rename cluster name | `string` | `""` | no |
| <a name="input_collector_image"></a> [collector\_image](#input\_collector\_image) | collector image name | `string` | `"miggoprod/miggo-infra-agent"` | no |
| <a name="input_collector_replicas"></a> [collector\_replicas](#input\_collector\_replicas) | Miggo collector replicas | `string` | `2` | no |
| <a name="input_collector_resource"></a> [collector\_resource](#input\_collector\_resource) | Miggo collector resource map | `map(any)` | <pre>{<br>  "cpu": 2048,<br>  "memory": 4096<br>}</pre> | no |
| <a name="input_collector_sg_ingress_cidr_blocks"></a> [collector\_sg\_ingress\_cidr\_blocks](#input\_collector\_sg\_ingress\_cidr\_blocks) | Ingress CIDRs of Miggo collector security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_collector_version"></a> [collector\_version](#input\_collector\_version) | Miggo collector image version | `string` | `"latest"` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | whether create a cluster or use existing one | `bool` | `true` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | # VPC variables. | `bool` | `true` | no |
| <a name="input_custom_iam_task_exec_role_arn"></a> [custom\_iam\_task\_exec\_role\_arn](#input\_custom\_iam\_task\_exec\_role\_arn) | ECS execution IAM Role overwrite, please pass arn of existing IAM Role | `string` | `""` | no |
| <a name="input_demo_sg_ingress_cidr_blocks"></a> [demo\_sg\_ingress\_cidr\_blocks](#input\_demo\_sg\_ingress\_cidr\_blocks) | Ingress CIDRs of Miggo collector security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_deploy_collector"></a> [deploy\_collector](#input\_deploy\_collector) | (Optional) If true will deploy will deploy collector as ECS service | `bool` | `true` | no |
| <a name="input_deploy_demo_app"></a> [deploy\_demo\_app](#input\_deploy\_demo\_app) | (Optional) If true will deploy will deploy collector as ECS service | `bool` | `false` | no |
| <a name="input_deploy_ecs_operator"></a> [deploy\_ecs\_operator](#input\_deploy\_ecs\_operator) | (Optional) If true will deploy will deploy ECS operator for OTeL as Lambda | `bool` | `true` | no |
| <a name="input_dockerhub_secret_name"></a> [dockerhub\_secret\_name](#input\_dockerhub\_secret\_name) | Dockerhub secert name | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | DNS domain to write collector address | `string` | n/a | yes |
| <a name="input_ecs_operator_s3"></a> [ecs\_operator\_s3](#input\_ecs\_operator\_s3) | Needed for fetching the lambda from Miggo s3 bucket | <pre>object({<br>    bucket  = string<br>    key     = string<br>    version = string<br>  })</pre> | <pre>{<br>  "bucket": "",<br>  "key": "",<br>  "version": ""<br>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"miggo"` | no |
| <a name="input_fargate"></a> [fargate](#input\_fargate) | whether the created cluster should run on fargate | `bool` | `true` | no |
| <a name="input_miggo_endpoint"></a> [miggo\_endpoint](#input\_miggo\_endpoint) | n/a | `string` | `"https://collector.miggo.io"` | no |
| <a name="input_miggo_secret_name"></a> [miggo\_secret\_name](#input\_miggo\_secret\_name) | Miggo secert name | `string` | n/a | yes |
| <a name="input_public"></a> [public](#input\_public) | n/a | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region, using providers region as default | `string` | `""` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Miggo tenant ID | `string` | `""` | no |
| <a name="input_vpc_availability_zones"></a> [vpc\_availability\_zones](#input\_vpc\_availability\_zones) | n/a | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | `"172.30.1.0/25"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id should be passed only if create\_vpc = false | `string` | `""` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | n/a | `list(string)` | <pre>[<br>  "172.30.1.0/27",<br>  "172.30.1.32/27"<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | n/a | `list(string)` | <pre>[<br>  "172.30.1.64/27",<br>  "172.30.1.96/27"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_collector_dns"></a> [collector\_dns](#output\_collector\_dns) | Miggo collector dns address |
| <a name="output_demo_dns"></a> [demo\_dns](#output\_demo\_dns) | Miggo demo dns address |
<!-- END_TF_DOCS -->  