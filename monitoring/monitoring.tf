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

  set {
    name  = "alertmanager.config.global.smtp_from"
    value = "prom@${var.domain}"
  }

  set {
    name  = "alertmanager.config.global.smtp_smarthost"
    value = "${var.smtp_host}:${var.smtp_port}"
  }

  set {
    name  = "alertmanager.config.global.smtp_auth_username"
    value = var.smtp_user
  }

  set {
    name  = "alertmanager.config.global.smtp_auth_password"
    value = var.smtp_password
  }

  set {
    name  = "alertmanager.config.global.smtp_smarthost"
    value = "false"
  }

  set {
    name  = "alertmanager.config.receivers[0].name"
    value = jsonencode("null")
  }

  set {
    name  = "alertmanager.config.receivers[1].name"
    value = "email"
  }

  set {
    name  = "alertmanager.config.receivers[1].email_configs[0].to"
    value = var.alert_email
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
          match = "Host(`prom.int.${var.domain}`)"
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

resource "kubernetes_manifest" "alertmanager_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "alertmanager"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }
    spec = {
      entryPoints = ["internal"]
      routes = [
        {
          match = "Host(`alert.int.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              namespace = "traefik"
              name      = "middleware-auth"
            }
          ]
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
