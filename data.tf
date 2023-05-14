data "kubernetes_config_map_v1" "vars" {
  metadata {
    name = "terraform-default-vars"
  }
}

data "kubernetes_secret_v1" "vars" {
  metadata {
    name = "terraform-default-vars"
  }
}
