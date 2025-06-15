data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.cluster_location
  project  = var.project_id
}


resource "kubernetes_storage_class" "neo4j_sc" {
  metadata {
    name = "neo4j-sc"
    labels = {
      creator = var.creator_name
    }
  }

  storage_provisioner = "kubernetes.io/gce-pd"

  parameters = {
    type = "pd-standard"
  }

  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

resource "kubernetes_secret" "clouddns_solver" {
  metadata {
    name      = "clouddns-dns01-solver-svc-acct"
    namespace = "cert-manager"
    labels = {
      creator = var.creator_name
    }
  }

  data = {
    "key.json" = var.dns_solver_key
  }

  type = "Opaque"
}


resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [kubernetes_secret.clouddns_solver]
}

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = yamldecode(templatefile("${path.module}/templates/cluster_issuer.yaml.tpl", {
    email        = var.email,
    project_id   = var.project_id,
    creator_name = var.creator_name
  }))

  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "neo4j_certificate" {
  manifest = yamldecode(templatefile("${path.module}/templates/certificate.yaml.tpl", {
    neo4j_domain = var.neo4j_domain,
    namespace    = var.neo4j_namespace,
    email        = var.email,
    creator_name = var.creator_name
  }))

  depends_on = [kubernetes_manifest.cluster_issuer]
}

resource "helm_release" "neo4j" {
  name             = "neo4j"
  repository       = "https://helm.neo4j.com/neo4j"
  chart            = "neo4j"
  namespace        = var.neo4j_namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/helm-values/neo4j-values.yaml.tpl", {
      tls_secret_name = "neo4j-tls"
    })
  ]

  depends_on = [kubernetes_manifest.neo4j_certificate, kubernetes_storage_class.neo4j_sc]
}
