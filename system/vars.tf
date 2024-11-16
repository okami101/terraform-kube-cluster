variable "chart_kured_version" {
  type = string
}

variable "chart_hccm_version" {
  type = string
}

variable "chart_cilium_version" {
  type = string
}

variable "k3s_version" {
  type = string
}

variable "network_cluster_cidr" {
  type = string
}

variable "load_balancers_location" {
  type = string
}

variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "hcloud_network_name" {
  type = string
}
