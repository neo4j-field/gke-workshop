variable "region" {
  description = "GCP region for the cluster"
  default = "europe-west1"
}

variable "location" {
  description = "GCP region or zone, use region for fault tolerances, but you end up with zones * worker_nodes. must reside inside the regions above"
  default     = "europe-west1-b"
}

variable "machine_type" {
  description = "GKE machine type"
  default     = "e2-highmem-2"
}

variable "neo4j_namespace" {
  description = "K8s namespace for Neo4j."
  default     = "neo4j"
}

variable "creator_name" {
  description = "Short tag used in naming for GCP."
}

variable "workshop_name" {
  description = "Workshop identifier used in naming on GCP."
}

variable "project_id" {
  description = "GCP project ID"
}

variable "email" {
  description = "Email for cert-manager/contact."
}

variable "neo4j_domain" {
  description = "Domain name used for Neo4j cert."
}

variable "dns_root_domain" {
  description = "Root DNS domain that you own and will delegate to GCP Cloud DNS."
  default = "neowork.me"
}

variable "dns_managed_zone" {
  description = "GCP managed zone for the above dns_root_domain."
  default = "neowork-root"
}

variable "worker_nodes" {
  description = "number of GKE worker nodes to create"
  default = 3
}

variable "neo4j_core_count" {
  description = "Number of Neo4j core members to deploy"
  type        = number
  default     = 3
}

variable "neo4j_password" {
  description = "The neo4j database user password. Restrictions apply."
}

variable "resource_cpu" {
  description = "The CPUs given to a Neo4j POD."
  default = 1
}

variable "resource_mem" {
  description = "The memory given to a Neo4j pod."
  default = "2Gi"
}
