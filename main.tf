module "base" {
  source              = "./base"
  domain              = data.kubernetes_config_map_v1.vars.data["domain"]
  http_basic_auth     = local.http_basic_auth
  cert_group_name     = data.kubernetes_config_map_v1.vars.data["cert_group_name"]
  hetzner_dns_api_key = data.kubernetes_secret_v1.vars.data["hetzner_dns_api_key"]
  acme_email          = data.kubernetes_config_map_v1.vars.data["acme_email"]
  zone_name           = data.kubernetes_config_map_v1.vars.data["zone_name"]
  whitelisted_ips     = jsondecode(data.kubernetes_secret_v1.vars.data["whitelisted_ips"])
}

module "data" {
  source                     = "./data"
  domain                     = data.kubernetes_config_map_v1.vars.data["domain"]
  redis_password             = data.kubernetes_secret_v1.vars.data["redis_password"]
  mongo_password             = data.kubernetes_secret_v1.vars.data["mongo_password"]
  mysql_password             = data.kubernetes_secret_v1.vars.data["mysql_password"]
  mysql_exporter_password    = data.kubernetes_secret_v1.vars.data["mysql_exporter_password"]
  pgsql_user                 = data.kubernetes_config_map_v1.vars.data["pgsql_user"]
  pgsql_password             = data.kubernetes_secret_v1.vars.data["pgsql_password"]
  pgsql_replication_password = data.kubernetes_secret_v1.vars.data["pgsql_replication_password"]
  pgadmin_default_email      = data.kubernetes_config_map_v1.vars.data["pgadmin_default_email"]
  pgadmin_default_password   = data.kubernetes_secret_v1.vars.data["pgadmin_default_password"]
  rabbitmq_default_user      = data.kubernetes_config_map_v1.vars.data["rabbitmq_default_user"]
  rabbitmq_default_password  = data.kubernetes_secret_v1.vars.data["rabbitmq_default_password"]
}

module "monitoring" {
  source              = "./monitoring"
  domain              = data.kubernetes_config_map_v1.vars.data["domain"]
  smtp_host           = data.kubernetes_config_map_v1.vars.data["smtp_host"]
  smtp_port           = data.kubernetes_config_map_v1.vars.data["smtp_port"]
  smtp_user           = data.kubernetes_config_map_v1.vars.data["smtp_user"]
  smtp_password       = data.kubernetes_secret_v1.vars.data["smtp_password"]
  grafana_db_password = data.kubernetes_secret_v1.vars.data["grafana_db_password"]
}

module "build" {
  source                       = "./build"
  domain                       = data.kubernetes_config_map_v1.vars.data["domain"]
  http_basic_username          = data.kubernetes_config_map_v1.vars.data["http_basic_username"]
  http_basic_password          = data.kubernetes_secret_v1.vars.data["http_basic_password"]
  gitea_db_password            = data.kubernetes_secret_v1.vars.data["gitea_db_password"]
  gitea_admin_username         = data.kubernetes_config_map_v1.vars.data["gitea_admin_username"]
  gitea_admin_password         = data.kubernetes_secret_v1.vars.data["gitea_admin_password"]
  gitea_admin_email            = data.kubernetes_config_map_v1.vars.data["gitea_admin_email"]
  image_pull_secret_namespaces = jsondecode(data.kubernetes_config_map_v1.vars.data["image_pull_secret_namespaces"])
  flux_receiver_hook           = data.kubernetes_secret_v1.vars.data["flux_receiver_hook"]
  flux_receiver_token          = data.kubernetes_secret_v1.vars.data["flux_receiver_token"]
  smtp_host                    = data.kubernetes_config_map_v1.vars.data["smtp_host"]
  smtp_port                    = data.kubernetes_config_map_v1.vars.data["smtp_port"]
  smtp_user                    = data.kubernetes_config_map_v1.vars.data["smtp_user"]
  smtp_password                = data.kubernetes_secret_v1.vars.data["smtp_password"]
  concourse_db_password        = data.kubernetes_secret_v1.vars.data["concourse_db_password"]
  concourse_user               = data.kubernetes_config_map_v1.vars.data["concourse_user"]
  concourse_password           = data.kubernetes_secret_v1.vars.data["concourse_password"]
  concourse_webhook_token      = data.kubernetes_secret_v1.vars.data["concourse_webhook_token"]
  flux_git_url                 = data.kubernetes_config_map_v1.vars.data["flux_git_url"]
  flux_git_branch              = data.kubernetes_config_map_v1.vars.data["flux_git_branch"]
  flux_ssh_username            = data.kubernetes_config_map_v1.vars.data["flux_ssh_username"]
  flux_ssh_private_key         = data.kubernetes_secret_v1.vars.data["flux_ssh_private_key"]
}

module "tools" {
  source                  = "./tools"
  domain                  = data.kubernetes_config_map_v1.vars.data["domain"]
  redis_password          = data.kubernetes_secret_v1.vars.data["redis_password"]
  redmine_db_password     = data.kubernetes_secret_v1.vars.data["redmine_db_password"]
  redmine_secret_key_base = data.kubernetes_secret_v1.vars.data["redmine_secret_key_base"]
  umami_db_password       = data.kubernetes_secret_v1.vars.data["umami_db_password"]
  n8n_db_password         = data.kubernetes_secret_v1.vars.data["n8n_db_password"]
  nocodb_db_password      = data.kubernetes_secret_v1.vars.data["nocodb_db_password"]
  nocodb_jwt_secret       = data.kubernetes_secret_v1.vars.data["nocodb_jwt_secret"]
  smtp_host               = data.kubernetes_config_map_v1.vars.data["smtp_host"]
  smtp_port               = data.kubernetes_config_map_v1.vars.data["smtp_port"]
  smtp_user               = data.kubernetes_config_map_v1.vars.data["smtp_user"]
  smtp_password           = data.kubernetes_secret_v1.vars.data["smtp_password"]
}
