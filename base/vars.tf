variable "domain" {
  type = string
}

variable "http_basic_auth" {
  type = string
}

variable "whitelisted_ips" {
  type = list(string)
}
