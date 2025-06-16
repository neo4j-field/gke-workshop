neo4j:
  name: "neo4j"
  resources:
    cpu: "1"
    memory: "2Gi"

  edition: "enterprise"
  acceptLicenseAgreement: "yes"
  minimumClusterSize: 3


ssl:
  bolt:
    enabled: true
    requiresClientAuth: false
    private_key: /ssl/tls.key
    public_certificate: /ssl/tls.crt
  https:
    enabled: true
    requiresClientAuth: false
    private_key: /ssl/tls.key
    public_certificate: /ssl/tls.crt

additionalVolumes:
  - name: ssl
    secret:
      secretName: ${tls_secret_name}

additionalVolumeMounts:
  - name: ssl
    mountPath: /ssl
    readOnly: true

services:
  neo4j:
    enabled: true

volumes:
  data:
    labels:
      data: "true"
    mode: dynamic
    dynamic:
      storageClassName: "neo4j-data"
      requests:
        storage: 10Gi
