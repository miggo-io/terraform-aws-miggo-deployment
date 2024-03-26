locals {
  azs = var.vpc_availability_zones == tolist([""]) ? ["${local.region}a", "${local.region}b"] : var.vpc_availability_zones
}
module "vpc" {
  count = var.create_vpc ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "${var.environment}-miggo-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  create_igw = true

  tags = local.tags
}