variable "domain" {
  type = string
}

variable "redis_password" {
  type = string
}

variable "mongo_password" {
  type = string
}

variable "mysql_password" {
  type = string
}

variable "mysql_exporter_password" {
  type = string
}

variable "pgsql_user" {
  type = string
}

variable "pgsql_password" {
  type = string
}

variable "pgsql_replication_password" {
  type = string
}

variable "pgadmin_default_email" {
  type = string
}

variable "pgadmin_default_password" {
  type = string
}

variable "pgsql_db_init" {
  type = list(object({
    username = string
    password = string
  }))
}

variable "rabbitmq_default_user" {
  type = string
}

variable "rabbitmq_default_password" {
  type = string
}
