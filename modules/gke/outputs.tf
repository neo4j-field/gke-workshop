output "cluster_name" {
  value = google_container_cluster.neo4j_cluster.name
}

output "cluster_location" {
  value = google_container_cluster.neo4j_cluster.location
}

output "project_id" {
  value = var.project_id
}
