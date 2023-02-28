module "base" {
  source              = "./base"
  domain              = var.domain
  http_basic_auth     = local.http_basic_auth
  cert_group_name     = var.cert_group_name
  hetzner_dns_api_key = var.hetzner_dns_api_key
  acme_email          = var.acme_email
  zone_name           = var.zone_name
  whitelisted_ips     = var.whitelisted_ips
}

module "data" {
  source                     = "./data"
  domain                     = var.domain
  redis_password             = var.redis_password
  mongo_password             = var.mongo_password
  mysql_password             = var.mysql_password
  mysql_exporter_password    = var.mysql_exporter_password
  pgsql_user                 = var.pgsql_user
  pgsql_password             = var.pgsql_password
  pgsql_replication_password = var.pgsql_replication_password
  pgadmin_default_email      = var.pgadmin_default_email
  pgadmin_default_password   = var.pgadmin_default_password
  minio_user                 = var.minio_user
  minio_password             = var.minio_password
  rabbitmq_default_user      = var.rabbitmq_default_user
  rabbitmq_default_password  = var.rabbitmq_default_password
  pgsql_db_init              = local.pgsql_db_init
}

module "monitoring" {
  source              = "./monitoring"
  domain              = var.domain
  smtp_host           = var.smtp_host
  smtp_port           = var.smtp_port
  smtp_user           = var.smtp_user
  smtp_password       = var.smtp_password
  grafana_db_password = var.grafana_db_password
}

module "build" {
  source                       = "./build"
  domain                       = var.domain
  http_basic_username          = var.http_basic_username
  http_basic_password          = var.http_basic_password
  gitea_db_password            = var.gitea_db_password
  gitea_admin_username         = var.gitea_admin_username
  gitea_admin_password         = var.gitea_admin_password
  gitea_admin_email            = var.gitea_admin_email
  image_pull_secret_namespaces = var.image_pull_secret_namespaces
  registry_endpoints           = var.registry_endpoints
  smtp_host                    = var.smtp_host
  smtp_port                    = var.smtp_port
  smtp_user                    = var.smtp_user
  smtp_password                = var.smtp_password
  concourse_db_password        = var.concourse_db_password
  concourse_user               = var.concourse_user
  concourse_password           = var.concourse_password
  concourse_access_key_id      = var.concourse_access_key_id
  concourse_secret_access_key  = var.concourse_secret_access_key
  concourse_bucket             = var.concourse_bucket
  concourse_webhook_token      = var.concourse_webhook_token
}

module "tools" {
  source                  = "./tools"
  domain                  = var.domain
  redis_password          = var.redis_password
  minio_user              = var.minio_user
  minio_password          = var.minio_password
  redmine_db_password     = var.redmine_db_password
  redmine_secret_key_base = var.redmine_secret_key_base
  umami_db_password       = var.umami_db_password
  n8n_db_password         = var.n8n_db_password
  nocodb_db_password      = var.nocodb_db_password
  nocodb_jwt_secret       = var.nocodb_jwt_secret
  smtp_host               = var.smtp_host
  smtp_port               = var.smtp_port
  smtp_user               = var.smtp_user
  smtp_password           = var.smtp_password
}
