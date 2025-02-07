resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  chart      = "kube-prometheus-stack"
  version    = var.chart_kube_prometheus_stack_version
  repository = "https://prometheus-community.github.io/helm-charts"

  name        = "kube-prometheus-stack"
  namespace   = kubernetes_namespace_v1.monitoring.metadata[0].name
  max_history = 2

  values = [
    file("${path.module}/values/prometheus-stack-values.yaml")
  ]

  set_list {
    name  = "kubeControllerManager.endpoints"
    value = var.server_ips
  }

  set_list {
    name  = "kubeScheduler.endpoints"
    value = var.server_ips
  }

  set_list {
    name  = "kubeEtcd.endpoints"
    value = var.server_ips
  }

  set {
    name  = "prometheus.prometheusSpec.externalUrl"
    value = "https://prom.${var.internal_domain}"
  }

  set {
    name  = "alertmanager.alertmanagerSpec.externalUrl"
    value = "https://am.${var.internal_domain}"
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
      entryPoints = ["private"]
      routes = [
        {
          match = "Host(`prom.${var.internal_domain}`)"
          kind  = "Rule"
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

resource "kubernetes_manifest" "alertmanager_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "alertmanager"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }
    spec = {
      entryPoints = ["private"]
      routes = [
        {
          match = "Host(`am.${var.internal_domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "alertmanager-operated"
              port = "http-web"
            }
          ]
        }
      ]
    }
  }
}
