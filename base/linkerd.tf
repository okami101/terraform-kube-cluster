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
