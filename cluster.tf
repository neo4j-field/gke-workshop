module "gke" {
  source           = "./modules/gke"
  project_id       = var.project_id
  region           = var.region
  gke_cluster_name = local.gke_cluster_name
  machine_type     = var.machine_type
  creator_name     = var.creator_name
  email            = var.email
}
