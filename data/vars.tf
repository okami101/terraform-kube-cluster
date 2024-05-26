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
