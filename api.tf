module "api" {
  source           = "./modules/api"
  project_id       = var.project_id
  loadbalancer_ip  = module.gke.neo4j_dns_ip
  image_tag        = var.image_tag

  depends_on = [module.neo4j]
}
