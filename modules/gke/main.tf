resource "google_service_account" "dns_solver" {
  account_id   = "dns-solver"
  display_name = "cert-manager DNS-01 solver (${var.email})"
  project      = var.project_id
}

resource "google_project_iam_member" "dns_admin_binding" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.dns_solver.email}"
}

resource "google_service_account_key" "dns_solver_key" {
  service_account_id = google_service_account.dns_solver.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_container_cluster" "neo4j_cluster" {
  name     = var.gke_cluster_name
  location = var.region
  project  = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  resource_labels = {
    creator = var.creator_name
  }

  network    = "default"
  subnetwork = "default"
}

resource "google_container_node_pool" "neo4j_pool" {
  name       = "neo4j-node-pool"
  cluster    = google_container_cluster.neo4j_cluster.name
  location   = var.region
  project    = var.project_id
  node_count = 3

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      creator = var.creator_name
    }

    tags = ["neo4j", "workshop"]
  }

  depends_on = [google_container_cluster.neo4j_cluster]
}
