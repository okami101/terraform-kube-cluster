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
}
