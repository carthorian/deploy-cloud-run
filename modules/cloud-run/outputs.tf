
output "cloud_run_url" {
  value = google_cloud_run_v2_service.run_service.uri
}

output "cloud_run_name" {
  value = google_cloud_run_v2_service.run_service.name
}