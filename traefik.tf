resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  chart   = "traefik/traefik"
  version = "10.24.2"

  name      = "traefik"
  namespace = "traefik"

  values = [
    file("values/traefik-values.yaml")
  ]
}
