resource "kubernetes_namespace" "okami" {
  metadata {
    name = "okami"
  }
}

resource "kubernetes_manifest" "okami_tls_store" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "TLSStore"
    metadata = {
      name      = "default"
      namespace = "okami"
    }
    spec = {
      defaultCertificate = {
        secretName = "wildcard-okami101-tls"
      }
    }
  }
}
