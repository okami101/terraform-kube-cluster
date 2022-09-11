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

variable "hetzner_dns_api_token" {
  type = string
}
