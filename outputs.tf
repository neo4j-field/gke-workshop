output "get_credentials_command" {
  value       = module.gke.get_credentials_command
  description = "gcloud command to configure kubectl context"
}

output "gke_cluster_name" {
  value       = module.gke.gke_cluster_name
  description = "GKE cluster name"
}

output "neo4j_browser_url" {
  value       = "https://${var.neo4j_domain}:7473"
  description = "URL to access the Neo4j Browser"
}

output "neo4j_bolt_url" {
  value       = "bolt://${var.neo4j_domain}:7687"
  description = "Bolt connection URI"
}

output "neo4j_http_url" {
  value       = "http://${var.neo4j_domain}:7474"
  description = "Optional HTTP (non-TLS) endpoint"
}

output "neo4j_core_pods" {
  value       = [for i in range(var.neo4j_core_count) : "neo4j-${i}.neo4j.${var.neo4j_namespace}.svc.cluster.local"]
  description = "Internal pod hostnames"
}

output "neo4j_password_hint" {
  value       = "See .neo4j_password.txt for your generated Neo4j password."
  description = "Instruction to locate the generated password"
}

output "api_token" {
  value       = module.api.api_token
  description = "API token from the API module"
  sensitive = true
}
