variable "domain" {
  type = string
}

variable "http_basic_auth" {
  type = string
}

variable "redis_password" {
  type = string
}

variable "couchdb_password" {
  type = string
}

variable "redmine_db_password" {
  type = string
}

variable "redmine_secret_key_base" {
  type = string
}

variable "umami_db_password" {
  type = string
}

variable "n8n_db_password" {
  type = string
}

variable "nocodb_db_password" {
  type = string
}

variable "nocodb_jwt_secret" {
  type = string
}

variable "whitelisted_ips" {
  type = list(string)
}

variable "velero_bucket" {
  type = string
}

variable "velero_credentials_file_path" {
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

variable "minio_user" {
  type = string
}

variable "minio_password" {
  type = string
}
