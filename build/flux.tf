provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url    = var.flux_git_url
    branch = var.flux_git_branch
    ssh = {
      username    = var.flux_ssh_username
      private_key = var.flux_ssh_private_key
    }
  }
}

resource "flux_bootstrap_git" "this" {
  components_extra = [
    "image-reflector-controller",
    "image-automation-controller"
  ]
}
