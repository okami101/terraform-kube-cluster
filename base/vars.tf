variable "k3s_version" {
  type = string
}

variable "domain" {
  type = string
}

variable "acme_email" {
  type = string
}

variable "http_basic_auth" {
  type      = string
  sensitive = true
}

variable "trusted_ips" {
  type = list(string)
}

variable "internal_ip_whitelist" {
  type = list(string)
}

variable "chart_longhorn_version" {
  type = string
}

variable "chart_kured_version" {
  type = string
}

variable "chart_traefik_version" {
  type = string
}

variable "chart_crowdsec_version" {
  type = string
}

variable "chart_cert_manager_version" {
  type = string
}

variable "chart_cert_manager_webhook_scaleway_version" {
  type = string
}

variable "scaleway_dns_access_key" {
  type      = string
  sensitive = true
}

variable "scaleway_dns_secret_key" {
  type      = string
  sensitive = true
}

variable "s3_endpoint" {
  type = string
}

variable "s3_region" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "s3_access_key" {
  type      = string
  sensitive = true
}

variable "s3_secret_key" {
  type      = string
  sensitive = true
}

variable "bouncer_api_key" {
  type      = string
  sensitive = true
}

variable "crowdsec_whitelists_config" {
  type = string
}

variable "crowdsec_bouncer_traefik_plugin_version" {
  type = string
}
