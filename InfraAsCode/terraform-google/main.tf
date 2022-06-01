terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }

  required_version = ">= 0.14"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.gcp_zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.gcp_zone
}

# Habilitando as API´s para o Projeto
resource "google_project_service" "project_apis" {
  project = var.project_id
  count = "${length(var.projetct_apis_list)}"
  service  = "${element(var.projetct_apis_list, count.index)}"
  disable_dependent_services = true
}

#User geral - Criacao
resource "google_service_account" "engdados-user" {
  account_id = "engdados-user"
  project = var.project_id
}

resource "google_project_iam_member" "engdados-user-member" {
  count   = "${length(var.iam_engdados_roles)}"
  project = var.project_id
  role    = "${element(values(var.iam_engdados_roles), count.index)}"
  member  = "serviceAccount:${google_service_account.engdados-user.email}"
}

# Install - Bucket do cluster
resource "google_storage_bucket" "bucket_install" {
  name          = var.bucket_install
  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true
  
  labels = {
    bucket="install"
  }

}

