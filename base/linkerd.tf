resource "kubernetes_namespace_v1" "linkerd" {
  metadata {
    name = "linkerd"
  }
}

resource "helm_release" "linkerd_crds" {
  chart      = "linkerd-crds"
  version    = "1.8.0"
  repository = "https://helm.linkerd.io/stable"

  name      = "linkerd-crds"
  namespace = kubernetes_namespace_v1.linkerd.metadata[0].name
}

resource "helm_release" "linkerd_control_plane" {
  chart      = "linkerd-control-plane"
  version    = "1.16.11"
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

  depends_on = [helm_release.linkerd_crds]
}
