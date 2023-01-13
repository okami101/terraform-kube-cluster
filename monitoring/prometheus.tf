resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  chart   = "prometheus-community/kube-prometheus-stack"
  version = "43.3.1"

  name      = "kube-prometheus-stack"
  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    file("values/prometheus-stack-values.yaml")
  ]
}

resource "kubernetes_manifest" "prometheus_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "prometheus"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
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
  chart   = "sstarcher/helm-exporter"
  version = "1.2.3+4dc0dfc"

  name      = "helm-exporter"
  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    file("values/helm-exporter-values.yaml")
  ]

  set {
    name  = "serviceMonitor.create"
    value = "true"
  }
}
