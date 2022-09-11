resource "helm_release" "nfs_provisioner" {
  chart   = "nfs-subdir-external-provisioner/nfs-subdir-external-provisioner"
  version = "4.0.17"

  name = "nfs-subdir-external-provisioner"

  set {
    name  = "nfs.server"
    value = var.nfs_server
  }

  set {
    name  = "nfs.path"
    value = var.nfs_path
  }

  set {
    name  = "storageClass.defaultClass"
    value = true
  }
}

resource "kubernetes_namespace" "openebs" {
  metadata {
    name = "openebs"
  }
}

resource "helm_release" "openebs_provisioner" {
  chart   = "openebs/openebs"
  version = "3.3.1"

  name      = "openebs"
  namespace = kubernetes_namespace.openebs.metadata[0].name
}
