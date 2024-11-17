variable "internal_domain" {
  type = string
}

variable "smtp_host" {
  type = string
}

variable "smtp_port" {
  type = string
}

variable "smtp_user" {
  type = string
}

variable "smtp_password" {
  type      = string
  sensitive = true
}

variable "loki_retention_period" {
  type    = string
  default = "744h"
}

variable "tempo_retention_period" {
  type    = string
  default = "24h"
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

variable "chart_grafana_version" {
  type = string
}

variable "chart_loki_version" {
  type = string
}

variable "chart_promtail_version" {
  type = string
}

variable "chart_kube_prometheus_stack_version" {
  type = string
}

variable "chart_tempo_version" {
  type = string
}

variable "server_ips" {
  type = list(string)
}
