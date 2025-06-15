variable "cluster_name" {}
variable "cluster_location" {}
variable "project_id" {}
variable "email" {}
variable "creator_name" {}
variable "neo4j_domain" {}
variable "neo4j_namespace" {}

variable "dns_solver_key" {
  description = "Base64-encoded key.json for cert-manager DNS-01 challenge"
  sensitive   = true
}
