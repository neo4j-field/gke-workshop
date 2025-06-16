resource "google_service_account" "dns_solver" {
  account_id   = "dns-solver"
  display_name = "cert-manager DNS-01 solver (${var.creator_name})"
  project      = var.project_id
}

resource "google_compute_address" "neo4j_ip" {
  name   = "${var.creator_name}-${var.workshop_name}-ip"
  region = var.region

  labels = {
    creator = var.creator_name
  }
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

resource "google_container_cluster" "gke_cluster" {
  name     = var.gke_cluster_name
  location = var.location
  project  = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = false

  resource_labels = {
    creator = var.creator_name
  }

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "neo4j_pool" {
  name       = "pool"
  cluster    = google_container_cluster.gke_cluster.name
  location   = var.location
  project    = var.project_id
  node_count = var.worker_nodes

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      creator = var.creator_name
      env = var.project_id
    }

    tags = ["workshop", var.workshop_name, var.creator_name]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [google_container_cluster.gke_cluster]
}
