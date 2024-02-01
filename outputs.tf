output "collector_dns" {
  value       = var.deploy_collector ? "https://${aws_route53_record.collector[0].fqdn}" : "Collector wasn't deployed"
  description = "Miggo collector dns address"
}
