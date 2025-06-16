module "gke" {
  source           = "./modules/gke"
  project_id       = var.project_id
  location         = var.location
  region           = var.region
  gke_cluster_name = local.gke_cluster_name
  machine_type     = var.machine_type
  creator_name     = var.creator_name
  email            = var.email
  workshop_name    = var.workshop_name
  neo4j_domain     = var.neo4j_domain
  dns_managed_zone = var.dns_managed_zone
  worker_nodes     = var.worker_nodes
}
