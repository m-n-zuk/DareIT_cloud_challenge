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

# # Define Google Cloud Load Balancer
# resource "google_compute_global_forwarding_rule" "website-forwarding-rule" {
#   name       = "website-forwarding-rule"
#   target     = google_compute_target_http_proxy.website-proxy.self_link
#   ip_address = google_compute_global_address.website-ip.address
#   port_range = "80"
# }

# resource "google_compute_target_http_proxy" "website-proxy" {
#   name = "website-proxy"
#   url_map = google_compute_url_map.website-url-map.self_link
# }

# resource "google_compute_url_map" "website-url-map" {
#   name = "website-url-map"

#   default_service = google_compute_backend_service.website-backend-service.self_link
# }

# resource "google_compute_backend_service" "website-backend-service" {
#   name = "website-backend-service"

#   backend {
#     default = true

#     # Specify Kubernetes Service endpoint
#     group = kubernetes_service.website-service.self_link
#   }

#   health_checks = [google_compute_health_check.website-health-check.self_link]
# }

# resource "google_compute_health_check" "website-health-check" {
#   name               = "website-health-check"
#   check_interval_sec = 10
#   timeout_sec        = 5
#   tcp_health_check {
#     port = "80"
#   }
# }

# # Define Kubernetes Service for website
# resource "kubernetes_service" "website-service" {
#   name = "website-service"

#   selector = {
#     app = kubernetes_deployment.website.spec[0].template.spec[0].metadata[0].labels.app
#   }

#   port {
#     protocol = "TCP"
#     port     = 80
#     target_port = 8080 # Port exposed by the container in the pod
#   }
# }
