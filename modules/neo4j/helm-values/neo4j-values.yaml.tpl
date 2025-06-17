neo4j:
  name: "neo4j"
  resources:
    cpu: ${resource_cpu}
    memory: ${resource_mem}

  edition: "enterprise"
  acceptLicenseAgreement: "yes"
  minimumClusterSize: ${neo4j_core_count}
  operations:
    enableServer: true


ssl:
  bolt:
    privateKey:
      secretName: neo4j-tls
      subPath: tls.key
    publicCertificate:
      secretName: neo4j-tls
      subPath: tls.crt

  https:
    privateKey:
      secretName: neo4j-tls
      subPath: tls.key
    publicCertificate:
      secretName: neo4j-tls
      subPath: tls.crt

services:
  neo4j:
    enabled: true
    spec:
      type: LoadBalancer
      loadBalancerIP: ${loadbalancer_ip}


volumes:
  data:
    labels:
      data: "true"
    mode: dynamic
    dynamic:
      storageClassName: "neo4j-data"
      requests:
        storage: 10Gi
