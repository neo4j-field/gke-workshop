variable "region" {
  description = "GCP region"
  default     = "europe-west1"
}

variable "machine_type" {
  description = "GKE machine type"
  default     = "e2-standard-2"
}

variable "neo4j_namespace" {
  description = "K8s namespace for Neo4j"
  default     = "neo4j"
}

variable "creator_name" {
  description = "Short tag used in naming"
}

variable "workshop_name" {
  description = "Workshop identifier used in naming"
}

variable "project_id" {
  description = "GCP project ID"
}

variable "email" {
  description = "Email for cert-manager/contact"
}

variable "neo4j_domain" {
  description = "Domain name used for Neo4j cert"
}
