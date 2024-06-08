resource "kubernetes_namespace_v1" "linkerd" {
  metadata {
    name = "linkerd"
  }
}

resource "helm_release" "linkerd_crds" {
  chart      = "linkerd-crds"
  version    = var.chart_linkerd_crds_version
  repository = "https://helm.linkerd.io/stable"

  name      = "linkerd-crds"
  namespace = kubernetes_namespace_v1.linkerd.metadata[0].name
}

resource "helm_release" "linkerd_control_plane" {
  chart      = "linkerd-control-plane"
  version    = var.chart_linkerd_control_plane_version
  repository = "https://helm.linkerd.io/stable"

  name      = "linkerd-control-plane"
  namespace = kubernetes_namespace_v1.linkerd.metadata[0].name

  set_sensitive {
    name  = "identityTrustAnchorsPEM"
    value = var.linkerd_ca
  }

  set_sensitive {
    name  = "identity.issuer.tls.crtPEM"
    value = var.linkerd_issuer
  }

  set_sensitive {
    name  = "identity.issuer.tls.keyPEM"
    value = var.linkerd_issuer_key
  }

  set {
    name  = "podMonitor.enabled"
    value = "true"
  }

  depends_on = [helm_release.linkerd_crds]
}


resource "helm_release" "linkerd_viz" {
  chart      = "linkerd-viz"
  version    = var.chart_linkerd_viz_version
  repository = "https://helm.linkerd.io/stable"

  name      = "linkerd-viz"
  namespace = kubernetes_namespace_v1.linkerd.metadata[0].name

  set {
    name  = "prometheus.enabled"
    value = "false"
  }

  set {
    name  = "prometheusUrl"
    value = "http://kube-prometheus-stack-prometheus.monitoring:9090/"
  }

  depends_on = [helm_release.linkerd_control_plane]
}
