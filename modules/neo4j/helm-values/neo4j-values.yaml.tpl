neo4j:
  name: "neo4j"
  resources:
    cpu: ${resource_cpu}
    memory: ${resource_mem}

  edition: "enterprise"
  acceptLicenseAgreement: "yes"
  minimumClusterSize: 3

  licenses:
    disableSubPathExpr: true
    mode: volume
    volume:
      secret:
        secretName: gds-bloom-license
        items:
          - key: gds.license
            path: gds.license
          - key: bloom.license
            path: bloom.license

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
        storage: ${data_pv_size}
  licenses:
      disableSubPathExpr: true
      mode: volume
      volume:
        secret:
          secretName: gds-bloom-license
          items:
            - key: gds.license
              path: gds.license
            - key: bloom.license
              path: bloom.license


env:
  NEO4J_PLUGINS: '["graph-data-science", "bloom", "apoc"]'
config:
  gds.enterprise.license_file: "/licenses/gds.license"
  dbms.security.procedures.unrestricted: "gds.*,apoc.*,bloom.*"
  server.unmanaged_extension_classes: "com.neo4j.bloom.server=/bloom,semantics.extension=/rdf"
  dbms.security.http_auth_allowlist: "/,/browser.*,/bloom.*"
  dbms.bloom.license_file: "/licenses/bloom.license"
  server.memory.heap.initial_size: ${neo4j_heap}
  server.memory.heap.max_size: ${neo4j_heap}
  server.memory.pagecache.size: ${neo4j_pg}
  initial.dbms.automatically_enable_free_servers: "true"
  server.bolt.tls_level: "OPTIONAL"
  dbms.integrations.cloud_storage.gs.project_id: "${project_id}"
  dbms.databases.seed_from_uri_providers: "URLConnectionSeedProvider,CloudSeedProvider"
