variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "namespace" {
  default = "neo4j"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
}

variable "api_secret_name" {
  default = "api-token"
}

variable "tls_secret_name" {
  default = "neo4j-tls"
}

variable "loadbalancer_ip" {
  description = "Static IP for API LoadBalancer"
  type        = string
}
