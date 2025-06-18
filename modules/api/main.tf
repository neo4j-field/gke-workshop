resource "kubernetes_deployment" "api" {
  metadata {
    name      = "neo4j-api"
    namespace = var.namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "neo4j-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "neo4j-api"
        }
      }

      spec {
        container {
          name  = "neo4j-api"
          image = "europe-west1-docker.pkg.dev/${var.project_id}/neo4j-api-repo/neo4j-workshop-api:${var.image_tag}"


          port {
            container_port = 443
          }

          env {
            name = "NEO4J_AUTH"
            value_from {
              secret_key_ref {
                name = "neo4j-auth"
                key  = "NEO4J_AUTH"
              }
            }
          }


          env {
            name  = "NEO4J_URI"
            value = "neo4j://neo4j.neo4j.svc.cluster.local:7687"
          }


          volume_mount {
            mount_path = "/certs"
            name       = "tls"
            read_only  = true
          }
        }

        volume {
          name = "tls"
          secret {
            secret_name = var.tls_secret_name
          }
        }
      }
    }
  }
  timeouts {
    create = "2m"
    update = "2m"
    delete = "1m"
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name      = "neo4j-api"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "neo4j-api"
    }

    type             = "LoadBalancer"
    load_balancer_ip = var.loadbalancer_ip

    port {
      name        = "https"
      port        = 443
      target_port = 443
    }
  }
}
