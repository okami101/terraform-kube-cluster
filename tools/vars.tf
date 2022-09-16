variable "domain" {
  type = string
}

variable "http_basic_auth" {
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

variable "whitelisted_ips" {
  type = list(string)
}
