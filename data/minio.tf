resource "kubernetes_namespace_v1" "minio" {
  metadata {
    name = "minio"
  }
}

resource "helm_release" "minio" {
  chart      = "minio"
  version    = "5.0.8"
  repository = "https://charts.min.io"

  name      = "minio"
  namespace = kubernetes_namespace_v1.minio.metadata[0].name

  values = [
    file("values/minio-values.yaml")
  ]

  set {
    name  = "rootUser"
    value = var.minio_user
  }

  set {
    name  = "rootPassword"
    value = var.minio_password
  }
}

resource "kubernetes_manifest" "s3_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "s3"
      namespace = kubernetes_namespace_v1.minio.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`s3.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "minio"
              kind = "Service"
              port = 9000
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "minio_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "minio"
      namespace = kubernetes_namespace_v1.minio.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`minio.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "minio-console"
              kind = "Service"
              port = 9001
            }
          ]
        }
      ]
    }
  }
}
