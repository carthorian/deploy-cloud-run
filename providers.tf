terraform {
  backend "local" {
    path = "state/terraform.tfstate"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.5"
}

provider "google" {
  project     = var.project
  credentials = file("deploy-sa.json")
}

data "google_client_config" "current" {}
