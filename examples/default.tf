module "miggo" {
    source  = "miggo-io/miggo-deployment/aws"    
    # version = x.y.z
    
    environment = "miggo"
    miggo_secret_name = "MIGGO_SECRET_NAME"
    dockerhub_secret_name = "MIGGO_SECRET_NAME"
    tenant_id = "MIGGO_TENANT_ID"

    domain_name = "YOUR_DOMAIN"
    public = true

    ecs_operator_s3 = {
        bucket = "..."
        key = "..."
        version = "..."
    }
}

output "miggo" {
    value = module.miggo
}