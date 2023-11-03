
variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "service_account_name" {
  description = "Service Account Name"
  type        = string
}

variable "service_account_roles" {
  description = "A set of IAM Roles for Service Account"
  type        = list(string)
  default     = []
}
