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

  # Available machine types:
  # https://cloud.google.com/compute/docs/machine-resource#machine_type_comparison

  # Recommended options for GKE workloads (as of June 2025):
  # - e2-highmem-2   : 2 vCPU, 16 GB RAM (default)
  # - e2-standard-4  : 4 vCPU, 16 GB RAM
  # - n2-standard-4  : 4 vCPU, 16 GB RAM (more predictable performance)
  # - n2-highmem-4   : 4 vCPU, 32 GB RAM (heavier memory-bound workloads)
  # - n2-highmem-8   : 8 vCPU, 64 GB RAM (large in-memory datasets)

  default = "e2-highmem-2"
}

variable "resource_cpu" {
  description = "vCPUs requested by a single Neo4j pod. Should match available CPU on node if running 1 pod per node."

  # Recommended values:
  # - e2-highmem-2   (2 vCPU): 1
  # - e2-standard-4  (4 vCPU): 3
  # - n2-highmem-4   (4 vCPU): 3
  # - n2-highmem-8   (8 vCPU): 6–7

  default = 1
}

variable "resource_mem" {
  description = "Memory requested by a Neo4j pod. Use 60–80% of node memory if 1 pod per node."

  # Recommended values:
  # - e2-highmem-2   (16 GiB): 12Gi
  # - e2-standard-4  (16 GiB): 10–12Gi
  # - n2-highmem-4   (32 GiB): 24–26Gi
  # - n2-highmem-8   (64 GiB): 48–52Gi

  default = "12Gi"
}

variable "neo4j_heap" {
  description = "Heap (min and max) for Neo4j. See above resource_mem for available memory"
  default = "3G"
}
variable "neo4j_pg" {
  description = "Pagecache memory for Neo4j. See above resource_mem for available memory"
  default = "8G"
}

variable "data_pv_size" {
  description = "requested size for the data volume. Number_of_users x db_size"
  default = "100Gi"
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

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
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

