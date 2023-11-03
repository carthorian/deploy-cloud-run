

resource "google_service_account" "service_account" {
  project      = var.project
  account_id   = var.service_account_name
  display_name = var.service_account_name
  description  = "${var.service_account_name} Service Account"
}

resource "google_project_iam_binding" "iam_binding" {
  count   = length(var.service_account_roles)
  project = var.project
  role    = var.service_account_roles[count.index]
  members = ["serviceAccount:${google_service_account.service_account.email}"]
}

