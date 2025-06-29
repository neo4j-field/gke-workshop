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
  filename = "${path.module}/rendered/cluster_issuer.yaml"
}


resource "null_resource" "apply_cluster_issuer" {
  provisioner "local-exec" {
    command = <<EOT
    echo "Applying ClusterIssuer..."
    kubectl apply -f ${path.module}/rendered/cluster_issuer.yaml
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
  filename = "${path.module}/rendered/neo4j_certificate.yaml"
}

resource "null_resource" "apply_neo4j_certificate" {
  depends_on = [
    null_resource.apply_cluster_issuer,
    kubernetes_namespace.neo4j,
    local_file.neo4j_certificate_yaml
  ]
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/rendered/neo4j_certificate.yaml"
  }
}

resource "kubernetes_secret" "gds_bloom_license" {
  count = fileexists(abspath("${path.root}/licenses/gds.license")) || fileexists(abspath("${path.root}/licenses/bloom.license")) ? 1 : 0

  metadata {
    name      = "gds-bloom-license"
    namespace = var.neo4j_namespace
  }

  data = merge(
      fileexists(abspath("${path.root}/licenses/gds.license")) ? {
      "gds.license" = file(abspath("${path.root}/licenses/gds.license"))
    } : {},
      fileexists(abspath("${path.root}/licenses/bloom.license")) ? {
      "bloom.license" = file(abspath("${path.root}/licenses/bloom.license"))
    } : {}
  )

  type = "Opaque"
}

resource "local_file" "neo4j_helm_values" {
  content  = templatefile("${path.module}/helm-values/neo4j-values.yaml.tpl", {
    resource_cpu    = var.resource_cpu
    resource_mem    = var.resource_mem
    neo4j_heap      = var.neo4j_heap
    neo4j_pg        = var.neo4j_pg
    loadbalancer_ip = var.loadbalancer_ip
    project_id      = var.project_id
    data_pv_size    = var.data_pv_size
  })
  filename = "${path.module}/rendered/neo4j-values.yaml"
}

resource "null_resource" "neo4j_cluster" {
  triggers = {
    resource_cpu = var.resource_cpu
    resource_mem = var.resource_mem
    neo4j_heap   = var.neo4j_heap
    neo4j_pg     = var.neo4j_pg
    neo4j_core_count = var.neo4j_core_count
    values_hash  = sha256(local_file.neo4j_helm_values.content)
  }

  provisioner "local-exec" {
    command = <<EOT
    for i in $(seq 0 $(( ${var.neo4j_core_count} - 1 ))); do
      echo "Installing/upgrading neo4j-$${i}"
      helm upgrade --install neo4j-$${i} \
        --repo https://helm.neo4j.com/neo4j neo4j \
        --namespace ${var.neo4j_namespace} \
        -f ${local_file.neo4j_helm_values.filename}
    done
    EOT
  }
  depends_on = [
    local_file.neo4j_helm_values,
    null_resource.apply_neo4j_certificate,
    kubernetes_storage_class.neo4j_sc,
    kubernetes_secret.gds_bloom_license
  ]
}

resource "null_resource" "wait_for_neo4j_ready" {
  provisioner "local-exec" {
    command = <<EOT
    echo "Waiting for public Bolt port to be reachable..."
    for i in {1..60}; do
      nc -zv ${var.neo4j_domain} 7687 && exit 0
      sleep 5
    done
    echo "Bolt port not ready after 300s"
    exit 1
    EOT
  }

  depends_on = [null_resource.neo4j_cluster]
}


resource "null_resource" "print_and_store_neo4j_password" {
  provisioner "local-exec" {
    command = <<EOT
    echo "Fetching Neo4j password and saving to .neo4j_password.txt..."
    kubectl get secret neo4j-auth -n ${var.neo4j_namespace} \
      -o jsonpath='{.data.NEO4J_AUTH}' | base64 -d > .neo4j_password.txt
    echo "" >> .neo4j_password.txt

    echo ""
    echo "======================================"
    echo "  Neo4j Credentials:"
    echo ""
    echo "   URL  : https://${var.neo4j_domain}:7473"
    echo "   Bolt : bolt://${var.neo4j_domain}:7687"
    echo -n "   Auth : " && cat .neo4j_password.txt
    echo "======================================"
    EOT
  }

  depends_on = [null_resource.wait_for_neo4j_ready]
}

