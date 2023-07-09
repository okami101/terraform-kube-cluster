variable "domain" {
  type = string
}

variable "redis_password" {
  type      = string
  sensitive = true
}

variable "mongo_password" {
  type      = string
  sensitive = true
}

variable "mysql_password" {
  type      = string
  sensitive = true
}

variable "mysql_exporter_password" {
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

variable "pgadmin_default_email" {
  type = string
}

variable "pgadmin_default_password" {
  type      = string
  sensitive = true
}

variable "rabbitmq_default_user" {
  type = string
}

variable "rabbitmq_default_password" {
  type      = string
  sensitive = true
}
