variable "domain" {
  type = string
}

variable "entry_point" {
  type = string
}

variable "redmine_db_password" {
  type      = string
  sensitive = true
}

variable "redmine_secret_key_base" {
  type      = string
  sensitive = true
}

variable "redmine_pvc_name" {
  type = string
}

variable "redmine_resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "redmine_resources_limits" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "umami_db_password" {
  type      = string
  sensitive = true
}

variable "umami_resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "umami_resources_limits" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "n8n_db_password" {
  type      = string
  sensitive = true
}

variable "n8n_pvc_name" {
  type = string
}

variable "n8n_resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "n8n_resources_limits" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "nocodb_db_password" {
  type      = string
  sensitive = true
}

variable "nocodb_jwt_secret" {
  type      = string
  sensitive = true
}

variable "nocodb_pvc_name" {
  type = string
}

variable "nocodb_resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "nocodb_resources_limits" {
  type = object({
    cpu    = string
    memory = string
  })
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
