variable "domain" {
  type = string
}

variable "http_basic_auth" {
  type      = string
  sensitive = true
}

variable "whitelisted_ips" {
  type      = list(string)
  sensitive = true
}
