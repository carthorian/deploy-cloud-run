
variable "deployment_fqdn" {
  description = "The FQDN for SSL cert"
  type        = string
}

variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "cloud_run_id" {
  description = "GCP Cloud Run ID"
  type        = string
}

variable "deployment_name" {
  description = "Deployment name for Cloud run"
  type        = string
}

variable "ssl_priv_key" {
  description = "Private key for User managed SSL"
  type        = string
}

variable "ssl_public_cert" {
  description = "Public cert for User managed SSL"
  type        = string
}

variable "location" {
  description = "Resource Region"
  type        = string
}

variable "use_selfsigned_cert" {
  description = "Select Google Managed or Selfsigned Cert"
  type        = bool
}
