variable "domain" {
  type = string
}

variable "http_basic_username" {
  type = string
}

variable "http_basic_password" {
  type = string
}

variable "gitea_db_password" {
  type = string
}

variable "gitea_admin_username" {
  type = string
}

variable "gitea_admin_password" {
  type = string
}

variable "gitea_admin_email" {
  type = string
}

variable "image_pull_secret_namespaces" {
  type = list(string)
}

variable "registry_endpoints" {
  type = list(object({
    name  = string
    url   = string
    token = string
  }))
}

variable "smtp_host" {
  type = string
}

variable "smtp_port" {
  type = number
}

variable "smtp_user" {
  type = string
}

variable "smtp_password" {
  type = string
}

variable "concourse_db_password" {
  type = string
}

variable "concourse_user" {
  type = string
}

variable "concourse_password" {
  type = string
}

variable "concourse_bucket" {
  type = string
}

variable "concourse_access_key_id" {
  type = string
}

variable "concourse_secret_access_key" {
  type = string
}

variable "concourse_webhook_token" {
  type = string
}
