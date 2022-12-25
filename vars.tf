variable "domain" {
  type = string
}

variable "image_pull_secret_namespaces" {
  type = list(string)
}

variable "registry_endpoints" {
  type = list(object({
    name  = string
    url   = string
    token = string
  }))
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

variable "umami_db_password" {
  type = string
}

variable "n8n_db_password" {
  type = string
}

variable "concourse_bucket" {
  type = string
}

variable "concourse_access_key_id" {
  type = string
}

variable "concourse_secret_access_key" {
  type = string
}

variable "concourse_webhook_token" {
  type = string
}

variable "velero_bucket" {
  type = string
}

variable "velero_credentials_file_path" {
  type = string
}
