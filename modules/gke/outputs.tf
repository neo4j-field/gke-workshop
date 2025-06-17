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
  description = "The kubectl context is already set to the workshop cluster, this was the command:"
  value = "gcloud container clusters get-credentials ${google_container_cluster.gke_cluster.name} --region ${var.location} --project ${var.project_id}"
}

output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.gke_cluster.name
}

output "neo4j_dns_ip" {
  description = "The IP address assigned to the Neo4j DNS A record"
  value       = google_compute_address.neo4j_ip.address
}
