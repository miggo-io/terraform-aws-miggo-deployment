module "miggo" {
    source  = "MiggoIO/miggo-deployment/aws"    
    # version = x.y.z
    
    environment = "miggo"
    miggo_secret_name = "MIGGO_SECRET_NAME"

    domain_name = "YOUR_DOMAIN"
}

output "miggo" {
    value = module.miggo
}