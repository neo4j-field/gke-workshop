output "api_token" {
  value       = random_password.api_token.result
  description = "Generated API token for accessing the Neo4j API"
}
