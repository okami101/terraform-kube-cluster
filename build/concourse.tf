resource "kubernetes_namespace_v1" "concourse" {
  metadata {
    name = "concourse"
  }
}

resource "helm_release" "concourse" {
  chart      = "concourse"
  version    = var.chart_concourse_version
  repository = "https://concourse-charts.storage.googleapis.com"

  name      = "concourse"
  namespace = kubernetes_namespace_v1.concourse.metadata[0].name

  values = [
    file("${path.module}/values/concourse-values.yaml")
  ]

  set {
    name  = "concourse.web.externalUrl"
    value = "https://concourse.${var.domain}"
  }

  set {
    name  = "concourse.web.auth.mainTeam.localUser"
    value = var.concourse_user
  }

  set {
    name  = "secrets.postgresPassword"
    value = var.concourse_db_password
  }

  set {
    name  = "secrets.localUsers"
    value = "${var.concourse_user}:${var.concourse_password}"
  }
}

resource "kubernetes_manifest" "concourse_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "concourse"
      namespace = kubernetes_namespace_v1.concourse.metadata[0].name
    }
    spec = {
      entryPoints = [var.entry_point]
      routes = [
        {
          match = "Host(`concourse.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "concourse-web"
              port = 8080
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_secret_v1" "concourse_registry" {
  metadata {
    name      = "registry"
    namespace = "concourse-main"
  }

  data = {
    name     = "registry.${var.domain}"
    username = var.http_basic_username
    password = var.http_basic_password
  }

  depends_on = [
    helm_release.concourse
  ]
}

resource "kubernetes_secret_v1" "concourse_webhook" {
  metadata {
    name      = "webhook-token"
    namespace = "concourse-main"
  }

  data = {
    value = var.concourse_webhook_token
  }

  depends_on = [
    helm_release.concourse
  ]
}
