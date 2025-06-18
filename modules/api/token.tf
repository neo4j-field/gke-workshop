resource "random_password" "api_token" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "api_token" {
  metadata {
    name      = "api-token"
    namespace = var.namespace
  }
  data = {
    token = random_password.api_token.result
  }
  type = "Opaque"
}

resource "local_file" "api_token_file" {
  content  = random_password.api_token.result
  filename = "${path.root}/.api_token.txt"
}
