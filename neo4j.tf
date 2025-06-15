module "neo4j" {
  source           = "./modules/neo4j"
  cluster_name     = module.gke.cluster_name
  cluster_location = module.gke.cluster_location
  project_id       = module.gke.project_id
  email            = var.email
  creator_name     = var.creator_name
  neo4j_domain     = var.neo4j_domain
  neo4j_namespace  = var.neo4j_namespace
}
