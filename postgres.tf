locals {
  grafana_password = random_string.db_password.result
}

resource "random_string" "db_password" {
  length  = 16
  special = true
}
