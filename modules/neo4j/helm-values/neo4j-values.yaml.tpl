neo4j:
  ssl:
    policy:
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

  extraVolumes:
    - name: ssl
      secret:
        secretName: ${tls_secret_name}

  extraVolumeMounts:
    - name: ssl
      mountPath: /ssl
      readOnly: true
