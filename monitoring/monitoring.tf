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

  set {
    name  = "kubeControllerManager.endpoints"
    value = "{${join(",", var.server_ips)}}"
  }

  set {
    name  = "kubeScheduler.endpoints"
    value = "{${join(",", var.server_ips)}}"
  }

  set {
    name  = "kubeProxy.endpoints"
    value = "{${join(",", var.server_ips)}}"
  }

  set {
    name  = "kubeEtcd.endpoints"
    value = "{${join(",", var.server_ips)}}"
  }
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
      entryPoints = ["internal"]
      routes = [
        {
          match = "Host(`prom.cp.${var.domain}`)"
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
              port = "http-web"
            }
          ]
        }
      ]
    }
  }
}
