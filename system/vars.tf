variable "internal_domain" {
  type = string
}

variable "chart_hccm_version" {
  type = string
}

variable "chart_cilium_version" {
  type = string
}

variable "chart_longhorn_version" {
  type = string
}

variable "s3_endpoint" {
  type = string
}

variable "s3_region" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "s3_access_key" {
  type      = string
  sensitive = true
}

variable "s3_secret_key" {
  type      = string
  sensitive = true
}

variable "network_cluster_cidr" {
  type = string
}

variable "k8s_service_port" {
  type    = number
  default = 6444
}

variable "load_balancers_location" {
  type = string
}

variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "hcloud_network_name" {
  type = string
}
