module "miggo" {
    source  = "MiggoIO/miggo-deployment/aws"    
    # version = x.y.z
    
    environment = "miggo"
    miggo_secret_name = "MIGGO_SECRET_NAME"
    dockerhub_secret_name = "MIGGO_SECRET_NAME"
    miggo_tenant_id = "MIGGO_TENAT_ID"

    domain_name = "YOUR_DOMAIN"
    certificate_arn = "YOUR_WILD_CARTIFICATE_ARN"

    create_cluster = false
    ecs_cluster_name = "YOUR_ECS_CLUSTER_NAME"
    
    create_vpc = false
    vpc_id = "YOUR_VPC_ID"
    vpc_private_subnets_ids = ["SUBNET_ID_1","SUBNET_ID_2"]
    vpc_public_subents_ids = ["SUBNET_ID_1","SUBNET_ID_2"]

    ecs_operator_s3 = {
        bucket = "..."
        key = "..."
        version = "..."
    }

}

output "miggo" {
    value = module.miggo
}