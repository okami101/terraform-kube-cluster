variable "domain" {
  type = string
}

variable "http_basic_username" {
  type = string
}

variable "http_basic_password" {
  type = string
}

variable "image_pull_secret_namespaces" {
  type = list(string)
}

variable "flux_receiver_hook" {
  type = string
}

variable "flux_receiver_token" {
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

variable "concourse_webhook_token" {
  type = string
}
