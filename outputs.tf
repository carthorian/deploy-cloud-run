output "cloud_run_url" {
  value = module.cloud-run.cloud_run_url
}

output "service_account_email" {
  value = module.service-account.service_account_email
}

output "lb_public_ip_address" {
  value = module.load-balancer.lb_public_ip_address
}
