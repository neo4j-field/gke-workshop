output "cluster_name" {
  value = google_container_cluster.neo4j_cluster.name
}

output "cluster_location" {
  value = google_container_cluster.neo4j_cluster.location
}

output "project_id" {
  value = var.project_id
}

output "dns_solver_key" {
  description = "Base64-encoded service account key for cert-manager DNS challenge"
  value       = google_service_account_key.dns_solver_key.private_key
  sensitive   = true
}
