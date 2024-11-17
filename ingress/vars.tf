variable "domain" {
  type = string
}

variable "internal_domain" {
  type = string
}

variable "load_balancer_name" {
  type = string
}

variable "load_balancer_type" {
  type    = string
  default = "lb11"
}

variable "acme_email" {
  type = string
}

variable "trusted_ips" {
  type    = list(string)
  default = ["127.0.0.1/32", "10.0.0.0/8"]
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
