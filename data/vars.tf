variable "domain" {
  type = string
}

variable "postgresql_resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "postgresql_resources_limits" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "redis_password" {
  type      = string
  sensitive = true
}

variable "redis_resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "redis_resources_limits" {
  type = object({
    cpu    = string
    memory = string
  })
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

variable "phpmyadmin_resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "phpmyadmin_resources_limits" {
  type = object({
    cpu    = string
    memory = string
  })
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

variable "pgadmin_resources_requests" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "pgadmin_resources_limits" {
  type = object({
    cpu    = string
    memory = string
  })
}

variable "rabbitmq_default_user" {
  type = string
}

variable "rabbitmq_default_password" {
  type      = string
  sensitive = true
}

variable "chart_postgresql_version" {
  type = string
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
