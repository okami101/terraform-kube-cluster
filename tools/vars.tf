variable "domain" {
  type = string
}

variable "redis_password" {
  type      = string
  sensitive = true
}

variable "redmine_db_password" {
  type      = string
  sensitive = true
}

variable "redmine_secret_key_base" {
  type      = string
  sensitive = true
}

variable "umami_db_password" {
  type      = string
  sensitive = true
}

variable "n8n_db_password" {
  type      = string
  sensitive = true
}

variable "nocodb_db_password" {
  type      = string
  sensitive = true
}

variable "nocodb_jwt_secret" {
  type      = string
  sensitive = true
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
