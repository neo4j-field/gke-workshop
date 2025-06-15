apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: neo4j-cert
  namespace: ${namespace}
  labels:
    creator: "${creator_name}"
spec:
  secretName: neo4j-tls
  dnsNames:
    - ${neo4j_domain}
  issuerRef:
    name: letsencrypt-dns
    kind: ClusterIssuer
