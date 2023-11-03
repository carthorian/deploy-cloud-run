locals {
  network = {
    enable  = false,
    network = "default",
    subnet  = "default"
  }
}

resource "google_project_service" "svc_cloudres" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "svc_certmgr" {
  project    = var.project
  service    = "certificatemanager.googleapis.com"
  depends_on = [google_project_service.svc_cloudres]
}

resource "google_project_service" "svc_run" {
  project    = var.project
  service    = "run.googleapis.com"
  depends_on = [google_project_service.svc_cloudres]
}

resource "google_project_service" "svc_iam" {
  project    = var.project
  service    = "iam.googleapis.com"
  depends_on = [google_project_service.svc_cloudres]
}

module "load-balancer" {
  source              = "./modules/load-balancer"
  project             = var.project
  cloud_run_id        = module.cloud-run.cloud_run_name
  deployment_name     = var.deployment_name
  ssl_priv_key        = var.ssl_priv_key
  ssl_public_cert     = var.ssl_public_cert
  location            = var.location
  use_selfsigned_cert = var.use_selfsigned_cert
  deployment_fqdn     = var.deployment_fqdn
  depends_on          = [module.cloud-run, google_project_service.svc_cloudres, google_project_service.svc_certmgr]
}

module "service-account" {
  source                = "./modules/service-account"
  project               = var.project
  service_account_name  = "${var.deployment_name}-access-sa"
  service_account_roles = []
  depends_on            = [google_project_service.svc_cloudres, google_project_service.svc_iam]
}

module "cloud-run" {
  source               = "./modules/cloud-run"
  project              = var.project
  service_account_name = module.service-account.service_account_email
  location             = var.location
  image_name           = "us-docker.pkg.dev/cloudrun/container/hello"
  deployment_name      = var.deployment_name
  max_scale            = var.max_scale
  min_scale            = var.min_scale
  allow_unauth         = var.allow_unauth
  is_public_deploy     = var.is_public_deploy
  network              = local.network
  depends_on           = [module.service-account, google_project_service.svc_cloudres, google_project_service.svc_run, google_project_service.svc_iam]
}