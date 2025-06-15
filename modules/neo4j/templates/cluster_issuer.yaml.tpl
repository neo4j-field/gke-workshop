apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns
  labels:
    creator: "${creator_name}"
spec:
  acme:
    email: "${email}"
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-dns-key
    solvers:
      - dns01:
          cloudDNS:
            project: "${project_id}"
            serviceAccountSecretRef:
              name: clouddns-dns01-solver-svc-acct
              key: key.json
