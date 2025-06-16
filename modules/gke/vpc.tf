resource "google_compute_network" "vpc" {
  name                    = "${var.creator_name}-${var.workshop_name}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.creator_name}-${var.workshop_name}-subnet"
  region        = var.region
  project       = var.project_id
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_router" "nat_router" {
  name    = "${var.creator_name}-${var.workshop_name}-router"
  network = google_compute_network.vpc.name
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.creator_name}-${var.workshop_name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
