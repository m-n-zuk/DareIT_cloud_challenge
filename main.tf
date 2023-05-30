# Define Kubernetes cluster
resource "google_container_cluster" "dareit-cluster-1" {

  count    = 1
  name     = "dareit-cluster-1"
  location = "us-central1"

  node_config {
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  initial_node_count = 1
}

resource "google_artifact_registry_repository" "dareit-repository" {

  location      = "us-central1"
  repository_id = "dareit-repository"
  format        = "docker"
}

# # Define static IP address
# resource "google_compute_address" "static-IP" {
#   name   = "static-ip-address"
#   region = "us-central1"
# }