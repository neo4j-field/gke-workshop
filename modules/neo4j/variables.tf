// variables for this module. We just pass stuff through from the outer module
variable "project_id" {}
variable "email" {}
variable "creator_name" {}
variable "neo4j_domain" {}
variable "neo4j_namespace" {}
variable "neo4j_core_count" {}
variable "resource_cpu" {}
variable "resource_mem" {}
variable "loadbalancer_ip" {}
variable "neo4j_heap" {}
variable "neo4j_pg" {}
variable "data_pv_size" {}

variable "dns_solver_key" {
  sensitive   = true
}
