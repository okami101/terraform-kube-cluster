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
}
