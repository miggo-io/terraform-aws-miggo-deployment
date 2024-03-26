##Global variables
variable "environment" {
  type        = string
  default     = "miggo"
  description = "Environment name"
}
variable "region" {
  type        = string
  default     = ""
  description = "AWS region, using providers region as default"
}

## DNS
variable "domain_name" {
  type        = string
  description = "DNS domain to write collector address"
}


## ECS variables
variable "create_cluster" {
  type        = bool
  default     = true
  description = "whether create a cluster or use existing one"
}

variable "fargate" {
  type        = bool
  default     = true
  description = "whether the created cluster should run on fargate"
}

#if create_cluster = false provide existing cluster name
variable "cluster_name" {
  type        = string
  default     = ""
  description = "ECS cluster name, if we want to deploy to existing one or rename cluster name"
}

## Miggo variables
variable "tenant_id" {
  type        = string
  default     = ""
  description = "Miggo tenant ID"
}

variable "deploy_collector" {
  type        = bool
  default     = true
  description = "(Optional) If true will deploy will deploy collector as ECS service"
}

variable "deploy_demo_app" {
  type        = bool
  default     = false
  description = "(Optional) If true will deploy will deploy collector as ECS service"
}

variable "deploy_ecs_operator" {
  type        = bool
  default     = true
  description = "(Optional) If true will deploy will deploy ECS operator for OTeL as Lambda"
}

variable "ecs_operator_s3" {
  type = object({
    bucket  = string
    key     = string
    version = string
  })
  default = {
    bucket  = ""
    key     = ""
    version = ""
  }
  description = "Needed for fetching the lambda from Miggo s3 bucket"
}

variable "collector_resource" {
  type = map(any)
  default = {
    cpu    = 2048,
    memory = 4096
  }
  description = "Miggo collector resource map"
}

variable "collector_replicas" {
  type        = string
  default     = 2
  description = "Miggo collector replicas"
}


variable "collector_version" {
  type        = string
  default     = "latest"
  description = "Miggo collector image version"
}

variable "collector_image" {
  type        = string
  default     = "miggoprod/miggo-infra-agent"
  description = "collector image name"
}

variable "miggo_secret_name" {
  type        = string
  description = "Miggo secert name"
}

variable "dockerhub_secret_name" {
  type        = string
  description = "Dockerhub secert name"
}

variable "miggo_endpoint" {
  type    = string
  default = "https://collector.miggo.io"
}

## VPC variables. 
variable "create_vpc" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type        = string
  description = "VPC id should be passed only if create_vpc = false"
  default     = ""
}

variable "vpc_cidr" {
  type    = string
  default = "172.30.1.0/25"
}

variable "vpc_availability_zones" {
  type    = list(string)
  default = [""]
}

variable "vpc_private_subnets" {
  type    = list(string)
  default = ["172.30.1.0/27", "172.30.1.32/27"]
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["172.30.1.64/27", "172.30.1.96/27"]
}

## IAM ECS execution role
variable "custom_iam_task_exec_role_arn" {
  type        = string
  default     = ""
  description = "ECS execution IAM Role overwrite, please pass arn of existing IAM Role"
}

## ENV vars
# {
#     "EXAMPLE_ENV" = "changethisvalue"
# }
variable "additional_collector_env_vars" {
  type        = any
  description = "Additional env variables of contorller, configure as map of key=values"
  default     = {}
}

## Self managed ACM certificates
variable "certificate_arn" {
  type        = string
  default     = ""
  description = "ARN of a certificate for Miggo collecotr, Will be used by ALB"
}

variable "collector_sg_ingress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Ingress CIDRs of Miggo collector security group"
}

variable "demo_sg_ingress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Ingress CIDRs of Miggo collector security group"
}

variable "public" {
  default = false
  type    = bool
}