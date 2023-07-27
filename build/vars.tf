variable "domain" {
  type = string
}

variable "registry_resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "registry_resources_limits" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "http_basic_username" {
  type = string
}

variable "http_basic_password" {
  type      = string
  sensitive = true
}

variable "image_pull_secret_namespaces" {
  type = list(string)
}

variable "flux_receiver_hook" {
  type = string
}

variable "flux_receiver_token" {
  type      = string
  sensitive = true
}

variable "gitea_db_password" {
  type      = string
  sensitive = true
}

variable "gitea_admin_username" {
  type = string
}

variable "gitea_admin_password" {
  type      = string
  sensitive = true
}

variable "gitea_admin_email" {
  type = string
}

variable "gitea_pvc_name" {
  type = string
}

variable "smtp_host" {
  type = string
}

variable "smtp_port" {
  type = string
}

variable "smtp_user" {
  type = string
}

variable "smtp_password" {
  type      = string
  sensitive = true
}

variable "concourse_db_password" {
  type      = string
  sensitive = true
}

variable "concourse_user" {
  type = string
}

variable "concourse_password" {
  type      = string
  sensitive = true
}

variable "concourse_webhook_token" {
  type      = string
  sensitive = true
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

variable "chart_concourse_version" {
  type = string
}

variable "chart_gitea_version" {
  type = string
}
