module "miggo" {
    source  = "MiggoIO/miggo-deployment/aws"    
    # version = x.y.z
    
    environment = "miggo"
    miggo_secret_name = "MIGGO_SECRET_NAME"
    dockerhub_secret_name = "MIGGO_SECRET_NAME"
    tenant_id = "MIGGO_TENANT_ID"

    domain_name = "YOUR_DOMAIN"
    certificate_arn = "YOUR_WILD_CARTIFICATE_ARN"

    create_cluster = false
    cluster_name = "YOUR_ECS_CLUSTER_NAME"
    
    create_vpc = false
    vpc_id = "YOUR_VPC_ID"
    vpc_private_subnets = ["SUBNET_ID_1","SUBNET_ID_2"]
    vpc_public_subnets = ["SUBNET_ID_1","SUBNET_ID_2"]

    ecs_operator_s3 = {
        bucket = "..."
        key = "..."
        version = "..."
    }

}

output "miggo" {
    value = module.miggo
}