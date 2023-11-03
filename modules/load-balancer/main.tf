
resource "google_compute_managed_ssl_certificate" "ssl_certificate_google" {
  count   = var.use_selfsigned_cert ? 0 : 1
  name    = "${var.deployment_name}-ssl-certificate-google-managed"
  project = var.project
  managed {
    domains = [var.deployment_fqdn]
  }
}

resource "google_compute_ssl_certificate" "ssl_certificate" {
  count       = var.use_selfsigned_cert ? 1 : 0
  name        = "${var.deployment_name}-ssl-certificate"
  description = "Example SSL certificate"
  private_key = file(var.ssl_priv_key)
  certificate = file(var.ssl_public_cert)
  project     = var.project
}

resource "google_compute_global_address" "loadbalancer-ip" {
  name       = "${var.deployment_name}-loadbalancer-ip"
  ip_version = "IPV4"
  project    = var.project
}

resource "google_compute_target_https_proxy" "target-https-proxy" {
  name             = "${var.deployment_name}-target-proxy"
  url_map          = google_compute_url_map.loadbalancer-map.self_link
  ssl_certificates = [var.use_selfsigned_cert ? google_compute_ssl_certificate.ssl_certificate[0].self_link : google_compute_managed_ssl_certificate.ssl_certificate_google[0].self_link]
}

resource "google_compute_url_map" "loadbalancer-map" {
  name            = "${var.deployment_name}-loadbalancer-map"
  default_service = google_compute_backend_service.backend.self_link
}

resource "google_compute_global_forwarding_rule" "lb-forwarding-rule" {
  name                  = "${var.deployment_name}-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.target-https-proxy.id
  ip_address            = google_compute_global_address.loadbalancer-ip.id
}

resource "google_compute_security_policy" "security_policy_for_backend" {
  description = "Security Policy for ${var.deployment_name}-backend"
  name        = "${var.deployment_name}-backend-security-policy"
  project     = var.project
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
  rule {
    action   = "throttle"
    priority = "2147483645"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      enforce_on_key = "IP"
      exceed_action  = "deny(403)"
      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }
    }
  }
  type = "CLOUD_ARMOR"
}

resource "google_compute_region_network_endpoint_group" "network_endpoint" {
  name                  = "${var.deployment_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.location
  cloud_run {
    service = var.cloud_run_id
  }
}

resource "google_compute_backend_service" "backend" {
  name       = "${var.deployment_name}-backend-service"
  project    = var.project
  enable_cdn = false
  backend {
    group = google_compute_region_network_endpoint_group.network_endpoint.id
  }
  security_policy = google_compute_security_policy.security_policy_for_backend.id
}

