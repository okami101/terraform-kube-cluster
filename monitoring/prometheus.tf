resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  chart      = "kube-prometheus-stack"
  version    = var.chart_kube_prometheus_stack_version
  repository = "https://prometheus-community.github.io/helm-charts"

  name      = "kube-prometheus-stack"
  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    file("${path.module}/values/prometheus-stack-values.yaml")
  ]
}

resource "kubernetes_manifest" "prometheus_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "prometheus"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }
    spec = {
      entryPoints = ["web"]
      routes = [
        {
          match = "Host(`prom.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              namespace = "traefik"
              name      = "middleware-auth"
            }
          ]
          services = [
            {
              name = "prometheus-operated"
              kind = "Service"
              port = 9090
            }
          ]
        }
      ]
    }
  }
}

resource "helm_release" "helm_exporter" {
  chart      = "helm-exporter"
  version    = var.chart_helm_exporter_version
  repository = "https://shanestarcher.com/helm-charts"

  name      = "helm-exporter"
  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    file("${path.module}/values/helm-exporter-values.yaml")
  ]

  set {
    name  = "serviceMonitor.create"
    value = "true"
  }
}
