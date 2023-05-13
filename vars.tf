variable "domain" {
  type = string
}

variable "image_pull_secret_namespaces" {
  type = list(string)
}

variable "flux_receiver_hook" {
  type = string
}

variable "flux_receiver_token" {
  type = string
}

variable "whitelisted_ips" {
  type = list(string)
}

variable "cert_group_name" {
  type = string
}

variable "hetzner_dns_api_key" {
  type = string
}

variable "acme_email" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "http_basic_username" {
  type = string
}

variable "http_basic_password" {
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

variable "grafana_db_password" {
  type = string
}

variable "rabbitmq_default_user" {
  type = string
}

variable "rabbitmq_default_password" {
  type = string
}

variable "gitea_db_password" {
  type = string
}

variable "concourse_db_password" {
  type = string
}

variable "concourse_user" {
  type = string
}

variable "concourse_password" {
  type = string
}

variable "concourse_webhook_token" {
  type = string
}

variable "gitea_admin_username" {
  type = string
}

variable "gitea_admin_password" {
  type = string
}

variable "gitea_admin_email" {
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

variable "redis_password" {
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
