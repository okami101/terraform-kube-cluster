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
      entryPoints = [var.entry_point]
      routes = [
        {
          match = "Host(`prom.${var.domain}`)"
          kind  = "Rule"
          middlewares = [for middleware in var.middlewares.prometheus : {
            namespace = "traefik"
            name      = "middleware-${middleware}"
          }]
          services = [
            {
              name = "prometheus-operated"
              port = "http-web"
            }
          ]
        }
      ]
    }
  }
}
