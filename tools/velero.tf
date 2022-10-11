resource "kubernetes_namespace_v1" "velero" {
  metadata {
    name = "velero"
  }
}

resource "helm_release" "velero" {
  chart   = "velero/velero"
  version = "2.31.9"

  name      = "velero"
  namespace = kubernetes_namespace_v1.velero.metadata[0].name

  values = [
    file("values/velero-values.yaml")
  ]

  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = var.velero_bucket
  }

  set {
    name  = "credentials.existingSecret"
    value = "gcp-credentials"
  }
}

resource "kubernetes_secret_v1" "gcp_credentials" {
  metadata {
    name      = "gcp-credentials"
    namespace = kubernetes_namespace_v1.velero.metadata[0].name
  }

  data = {
    cloud = file(var.velero_credentials_file_path)
  }
}
