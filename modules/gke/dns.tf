resource "google_dns_record_set" "neo4j_dns" {
  name         = "${trim(var.neo4j_domain, ".")}." # must end with a dot, so optionally remove and add again
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_managed_zone
  rrdatas = [google_compute_address.neo4j_ip.address]
}
