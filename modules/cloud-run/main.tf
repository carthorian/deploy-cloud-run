
module "cloud-run-service-account" {
  source                = "../../modules/service-account"
  project               = var.project
  service_account_name  = "${var.deployment_name}-cloud-run-sa"
  service_account_roles = []
}

resource "google_cloud_run_v2_service" "run_service" {
  project      = var.project
  name         = var.deployment_name
  location     = var.location
  launch_stage = "BETA"
  ingress      = var.is_public_deploy ? "INGRESS_TRAFFIC_ALL" : "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    scaling {
      min_instance_count = var.min_scale
      max_instance_count = var.max_scale
    }

    max_instance_request_concurrency = 100
    session_affinity                 = true
    service_account                  = module.cloud-run-service-account.service_account_email
    timeout                          = "120s"

    containers {
      image = var.image_name
      name  = var.deployment_name
      ports {
        container_port = 8080
      }
      resources {
        startup_cpu_boost = false
        cpu_idle          = true
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
      startup_probe {
        initial_delay_seconds = 0
        timeout_seconds       = 1
        period_seconds        = 3
        failure_threshold     = 1
        tcp_socket {
          port = 8080
        }
      }
      liveness_probe {
        initial_delay_seconds = 0
        timeout_seconds       = 1
        period_seconds        = 3
        failure_threshold     = 1
        http_get {
          path = "/"
        }
      }
    }

    dynamic "vpc_access" {
      for_each = var.network.enable ? ["enable"] : []
      content {
        network_interfaces {
          network    = var.network.network
          subnetwork = var.network.subnet
        }
        egress = "PRIVATE_RANGES_ONLY"
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      var.allow_unauth ? "allUsers" : "serviceAccount:${var.service_account_name}"
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  project     = var.project
  location    = var.location
  service     = google_cloud_run_v2_service.run_service.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
