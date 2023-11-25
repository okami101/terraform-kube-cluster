variable "domain" {
  type = string
}

variable "entry_point" {
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

variable "mongodb_password" {
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

variable "rabbitmq_user" {
  type = string
}

variable "rabbitmq_password" {
  type      = string
  sensitive = true
}

variable "chart_postgresql_version" {
  type = string
}

variable "chart_mysql_version" {
  type = string
}

variable "chart_mongodb_version" {
  type = string
}

variable "chart_redis_version" {
  type = string
}

variable "chart_rabbitmq_version" {
  type = string
}
