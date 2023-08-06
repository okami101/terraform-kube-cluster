resource "kubernetes_namespace_v1" "influxdb" {
  metadata {
    name = "influxdb"
  }
}

resource "helm_release" "influxdb" {
  chart      = "influxdb"
  version    = var.chart_influxdb_version
  repository = "https://charts.bitnami.com/bitnami"

  name      = "influxdb"
  namespace = kubernetes_namespace_v1.influxdb.metadata[0].name

  values = [
    file("${path.module}/values/influxdb-values.yaml")
  ]

  set {
    name  = "auth.admin.password"
    value = var.influxdb_admin_password
  }
}

resource "kubernetes_manifest" "influxdb_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "influxdb"
      namespace = kubernetes_namespace_v1.influxdb.metadata[0].name
    }
    spec = {
      entryPoints = [var.entry_point]
      routes = [
        {
          match = "Host(`influxdb.${var.domain}`)"
          kind  = "Rule"
          middlewares = [for middleware in var.middlewares.influxdb : {
            namespace = "traefik"
            name      = "middleware-${middleware}"
          }]
          services = [
            {
              name = "influxdb"
              kind = "Service"
              port = 8086
            }
          ]
        }
      ]
    }
  }
}
