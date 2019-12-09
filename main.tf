variable "initial_node_count" {
  type = number
  default = 1
}

variable "node_disk_size_gb" {
  type = number
  default = 50
}

variable "primary_node_pool_machine_type" {
  type = string
  default = "n1-standard-1"
}

variable "region" {
  type = string
  default = "europe-west3"
}

variable "node_locations" {
  type = list(string)
  default = [ "europe-west3-a", "europe-west3-b", "europe-west3-c" ]
}


data "google_container_engine_versions" "default" {
  location       = var.region
}


resource "google_container_cluster" "primary" {
  name = "gke-cluster"

  location = var.region
  remove_default_node_pool = true
  initial_node_count = 1

  node_locations = var.node_locations
  min_master_version = data.google_container_engine_versions.default.latest_master_version

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes = true
    master_ipv4_cidr_block = "172.16.0.32/28"
  }

  ip_allocation_policy {
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled = true
    provider = "CALICO"
  }

}

resource "google_container_node_pool" "primary_nodes" {
  name = "primary-node-pool"
  cluster = google_container_cluster.primary.name
  initial_node_count = var.initial_node_count

  location = var.region

  node_config {
    machine_type = var.primary_node_pool_machine_type
    disk_size_gb = var.node_disk_size_gb
    tags = ["ingress-allow-lb"]

    oauth_scopes = [
      "storage-ro",
      "logging-write",
      "monitoring"
    ]
  }

  management {
    auto_repair = true
    auto_upgrade = true
  }
}

output "gke_cluster" {
  value = google_container_cluster.primary
}
