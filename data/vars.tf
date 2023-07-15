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

variable "mysql_backup_pvc_name" {
  type = string
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

variable "pgsql_backup_pvc_name" {
  type = string
}

variable "pgadmin_default_email" {
  type = string
}

variable "pgadmin_default_password" {
  type      = string
  sensitive = true
}

variable "pgadmin_pvc_name" {
  type = string
}

variable "rabbitmq_default_user" {
  type = string
}

variable "rabbitmq_default_password" {
  type      = string
  sensitive = true
}

variable "chart_prometheus_mongodb_exporter_version" {
  type = string
}

variable "chart_prometheus_mysql_exporter_version" {
  type = string
}

variable "chart_prometheus_postgres_exporter_version" {
  type = string
}

variable "chart_prometheus_redis_exporter_version" {
  type = string
}
