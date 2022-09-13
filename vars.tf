variable "domain" {
  type = string
}

variable "whitelisted_ips" {
  type = list(string)
}

variable "nfs_server" {
  type = string
}

variable "nfs_path" {
  type = string
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

variable "basic_http_auth" {
  type = string
}

variable "smtp_host" {
  type = string
}

variable "smtp_user" {
  type = string
}

variable "smtp_password" {
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

variable "minio_user" {
  type = string
}

variable "minio_password" {
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

variable "matomo_db_password" {
  type = string
}
