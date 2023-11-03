
variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "service_account_name" {
  description = "Service Account Name for Cloud Run"
  type        = string
}

variable "location" {
  description = "GCP Region name for deployments"
  type        = string
}

variable "image_name" {
  description = "Image name for Cloud run"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "deployment_name" {
  description = "Deployment name for Cloud run"
  type        = string
}

variable "max_scale" {
  description = "Max number of pod count"
  type        = number
  default     = 2
}

variable "min_scale" {
  description = "Min number of pod count"
  type        = number
  default     = 1
}

variable "allow_unauth" {
  description = "Allow unauthenticated users"
  type        = bool
  default     = false
}

variable "is_public_deploy" {
  description = "Allow traffic from Public internet"
  type        = bool
  default     = false
}

variable "network" {
  description = "VPC Network detils"
  default     = {}
  type = object({
    enable  = optional(bool, false)
    network = optional(string, "")
    subnet  = optional(string, "")
  })
}