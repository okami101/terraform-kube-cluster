variable "domain" {
  type = string
}

variable "entry_point" {
  type = string
}

variable "middlewares" {
  type = map(list(string))
}

variable "image_pull_secret_namespaces" {
  type = list(string)
}

variable "redis_password" {
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

variable "chart_concourse_version" {
  type = string
}

variable "chart_gitea_version" {
  type = string
}
