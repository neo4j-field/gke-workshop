resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "neo4j" {
  metadata {
    name = var.neo4j_namespace
  }
}

resource "kubernetes_storage_class" "neo4j_sc" {
  metadata {
    name = "neo4j-data"
    labels = {
      creator = var.creator_name
    }
  }

  storage_provisioner = "pd.csi.storage.gke.io"

  parameters = {
    type = "pd-standard" # or pd-ssd
  }

  reclaim_policy         = "Delete"
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
    "key.json" = base64decode(var.dns_solver_key)
  }
  type = "Opaque"
  depends_on = [kubernetes_namespace.cert_manager]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"

  set {
    name  = "crds.enabled"
    value = "true"
  }
  depends_on = [kubernetes_namespace.cert_manager, kubernetes_secret.clouddns_solver]
}

resource "null_resource" "wait_for_clusterissuer_crd" {
  provisioner "local-exec" {
    command = <<EOT
    echo "Waiting for ClusterIssuer CRD to be registered..."
    for i in {1..20}; do
      kubectl get crd clusterissuers.cert-manager.io && exit 0
      echo "Still waiting..."
      sleep 5
    done
    echo "Timeout: ClusterIssuer CRD not found after 100 seconds" >&2
    exit 1
    EOT
  }
  depends_on = [helm_release.cert_manager]
}

locals {
  cluster_issuer_yaml = templatefile("${path.module}/templates/cluster_issuer.yaml.tpl", {
    email        = var.email
    project_id   = var.project_id
    creator_name = var.creator_name
  })
}

resource "local_file" "cluster_issuer_yaml" {
  content  = local.cluster_issuer_yaml
  filename = "${path.module}/templates/cluster_issuer.yaml"
}


resource "null_resource" "apply_cluster_issuer" {
  provisioner "local-exec" {
    command = <<EOT
    echo "Applying ClusterIssuer..."
    kubectl apply -f ${path.module}/templates/cluster_issuer.yaml
    EOT
  }
  depends_on = [null_resource.wait_for_clusterissuer_crd]
}

locals {
  neo4j_certificate_yaml = templatefile("${path.module}/templates/certificate.yaml.tpl", {
    neo4j_domain = var.neo4j_domain
    namespace    = var.neo4j_namespace
    email        = var.email
    creator_name = var.creator_name
  })
}

resource "local_file" "neo4j_certificate_yaml" {
  content  = local.neo4j_certificate_yaml
  filename = "${path.module}/templates/neo4j_certificate.yaml"
}

resource "null_resource" "apply_neo4j_certificate" {
  depends_on = [
    null_resource.apply_cluster_issuer,
    kubernetes_namespace.neo4j,
    local_file.neo4j_certificate_yaml
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/templates/neo4j_certificate.yaml"
  }
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

  depends_on = [
    null_resource.apply_neo4j_certificate,
    kubernetes_storage_class.neo4j_sc
  ]
}
