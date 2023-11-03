
output "lb_public_ip_address" {
  value = google_compute_global_address.loadbalancer-ip.address
}
