module "miggo" {
  source  = "MiggoIO/miggo-deployment/aws"    
  # version = x.y.z
  
  environment           = "miggo"
  miggo_secret_name     = "MIGGO_SECRET_NAME"
  dockerhub_secret_name = "MIGGO_SECRET_NAME"
  tenant_id             = "..."

  domain_name         = "YOUR_DOMAIN"
  deploy_ecs_operator = true
  deploy_collector    = true
  deploy_demo_app     = true
  public              = true
  fargate = false


  ecs_operator_s3 = {
    bucket  = "..."
    key     = "..."
    version = "..."
  }

}

output "miggo" {
    value = module.miggo
}