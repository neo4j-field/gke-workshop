output "get_credentials_command" {
  value       = module.gke.get_credentials_command
  description = "gcloud command to configure kubectl context"
}

output "gke_cluster_name" {
  value       = module.gke.gke_cluster_name
  description = "GKE cluster name"
}

output "neo4j_browser_url" {
  value       = "https://${var.neo4j_domain}:7473/browser/preview/"
  description = "URL to access the Neo4j Browser"
}

output "neo4j_bolt_url" {
  value       = "neo4j://${var.neo4j_domain}:7687"
  description = "Bolt connection URI"
}

output "neo4j_core_pods" {
  value       = [for i in range(var.neo4j_core_count) : "neo4j-${i}.neo4j.${var.neo4j_namespace}.svc.cluster.local"]
  description = "Internal pod hostnames"
}

output "neo4j_credentials" {
  value       = "Neo4j credentials (also in .neo4j_password.txt):\n  URL  : https://${var.neo4j_domain}:7473\n  Bolt : bolt://${var.neo4j_domain}:7687"
  description = "Neo4j connection info and password"
}

output "api_info" {
  value       = "API / Admin UI token can be found in also in .api_token.txt"
  description = "Workshop API token"
}

output "ui_url" {
  value = "The admin UI can be found at https://${var.neo4j_domain}"
}
