variable "project_id" {}
variable "email" {}
variable "creator_name" {}
variable "neo4j_domain" {}
variable "neo4j_namespace" {}
variable "neo4j_core_count" {}
variable "resource_cpu" {}
variable "resource_mem" {}
variable "loadbalancer_ip" {}

variable "dns_solver_key" {
  sensitive   = true
}
