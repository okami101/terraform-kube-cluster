resource "null_resource" "encrypted_admin_password" {
  triggers = {
    orig = data.kubernetes_secret_v1.vars.data["http_basic_password"]
    pw   = bcrypt(data.kubernetes_secret_v1.vars.data["http_basic_password"])
  }

  lifecycle {
    ignore_changes = [triggers["pw"]]
  }
}

locals {
  http_basic_auth = "${data.kubernetes_config_map_v1.vars.data["http_basic_username"]}:${null_resource.encrypted_admin_password.triggers.pw}"
}
