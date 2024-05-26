variable "domain" {
  type = string
}

variable "redis_password" {
  type      = string
  sensitive = true
}

variable "mysql_root_password" {
  type      = string
  sensitive = true
}

variable "mysql_user" {
  type = string
}

variable "mysql_password" {
  type      = string
  sensitive = true
}

variable "pgsql_admin_password" {
  type      = string
  sensitive = true
}

variable "pgsql_user" {
  type = string
}

variable "pgsql_password" {
  type      = string
  sensitive = true
}

variable "pgsql_replication_password" {
  type      = string
  sensitive = true
}

variable "chart_postgresql_version" {
  type = string
}

variable "chart_mysql_version" {
  type = string
}

variable "chart_redis_version" {
  type = string
}

variable "chart_cnpg_version" {
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
