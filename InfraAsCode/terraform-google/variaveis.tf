# GCP Project ID 
variable "project_id" {
  type = string
  description = "GCP Project ID"
}

# Region to use for Subnet 1
variable "region" {
  type = string
  description = "GCP Region"
}

# Zone used for VMs
variable "gcp_zone" {
  type = string
  description = "GCP Zone"
}

variable "engdados_serviceAccount" {
  type = string
  description = ""
}

variable "bucket_install" {
  type = string
  description = ""
}

variable "projetct_apis_list" {
  type = list
}

variable "iam_engdados_roles" {
  type = map
}

