resource "null_resource" "encrypted_admin_password" {
  triggers = {
    orig = var.http_basic_password
    pw   = bcrypt(var.http_basic_password)
  }

  lifecycle {
    ignore_changes = [triggers["pw"]]
  }
}

locals {
  http_basic_auth = "${var.http_basic_username}:${null_resource.encrypted_admin_password.triggers.pw}"

  pgsql_db_init = [
    {
      username = "grafana"
      password = var.grafana_db_password
    },
    {
      username = "gitea"
      password = var.gitea_db_password
    },
    {
      username = "concourse"
      password = var.concourse_db_password
    },
    {
      username = "redmine"
      password = var.redmine_db_password
    },
  ]
}
