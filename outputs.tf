output "get_credentials_command" {
  value       = module.gke.get_credentials_command
  description = "gcloud command to configure kubectl context"
}

output "gke_cluster_name" {
  value       = module.gke.gke_cluster_name
  description = "GKE cluster name"
}
