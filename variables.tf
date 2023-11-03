variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "GCP Region name for deployments"
  type        = string
}

variable "deployment_name" {
  description = "Deployment name for Cloud run"
  type        = string
}

variable "max_scale" {
  description = "Max number of instance for Cloud Run"
  type        = number
  default     = 2
}

variable "min_scale" {
  description = "Min number of instance for Cloud Run"
  type        = number
  default     = 1
}

variable "ssl_priv_key" {
  description = "Private key for User managed SSL"
  type        = string
}

variable "ssl_public_cert" {
  description = "Public cert for User managed SSL"
  type        = string
}

variable "use_selfsigned_cert" {
  description = "Select Google Managed or Selfsigned Cert"
  type        = bool
}

variable "deployment_fqdn" {
  description = "FQDN for Google managed SSL cert"
  type        = string
}
