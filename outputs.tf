output "collector_dns" {
  value       = var.deploy_collector ? "https://${aws_route53_record.collector[0].fqdn}" : "Collector wasn't deployed"
  description = "Miggo collector dns address"
}

output "demo_dns" {
  value       = var.deploy_demo_app ? "https://${aws_route53_record.demo[0].fqdn}" : "Collector wasn't deployed"
  description = "Miggo demo dns address"
}