module "neo4j" {
  source           = "./modules/neo4j"
  project_id       = module.gke.project_id

  email            = var.email
  creator_name     = var.creator_name
  neo4j_domain     = var.neo4j_domain
  neo4j_namespace  = var.neo4j_namespace
  neo4j_core_count = var.neo4j_core_count
  resource_cpu     = var.resource_cpu
  resource_mem     = var.resource_mem
  neo4j_heap       = var.neo4j_heap
  neo4j_pg         = var.neo4j_pg
  data_pv_size     = var.data_pv_size
  dns_solver_key   = module.gke.dns_solver_key
  loadbalancer_ip  = module.gke.neo4j_dns_ip

  depends_on = [module.gke]

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}
