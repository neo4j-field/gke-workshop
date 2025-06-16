output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "cluster_location" {
  value = google_container_cluster.gke_cluster.location
}

output "project_id" {
  value = var.project_id
}

output "dns_solver_key" {
  description = "Base64-encoded service account key for cert-manager DNS challenge"
  value       = google_service_account_key.dns_solver_key.private_key
  sensitive   = true
}

output "get_credentials_command" {
  description = "Run this to configure kubectl context for the workshop cluster"
  value = "gcloud container clusters get-credentials ${google_container_cluster.gke_cluster.name} --region ${var.region} --project ${var.project_id}"
}

output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.gke_cluster.name
}
