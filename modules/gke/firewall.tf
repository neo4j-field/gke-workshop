resource "google_compute_firewall" "neo4j_https_bolt" {
  name    = "${var.creator_name}-${var.workshop_name}-allow-neo4j"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["7473", "7687"]
  }

  # Optional: allow unsecured HTTP browser access
  allow {
    protocol = "tcp"
    ports    = ["7474"]
  }

  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["workshop", var.workshop_name, var.creator_name]

  priority = 1000
}
