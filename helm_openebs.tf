resource "helm_release" "openebs" {
   depends_on = ["null_resource.helm_init"]
   namespace  = "openebs"
   name       = "openebs"
   repository = "${helm_repository.stable.metadata.0.name}"
   chart      = "openebs"
   values = [ <<RAW_YAML

# Default values for openebs.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

rbac:
  # Specifies whether RBAC resources should be created
  create: true

serviceAccount:
  create: true
  name:

image:
  pullPolicy: IfNotPresent

apiserver:
  image: "quay.io/openebs/m-apiserver"
  imageTag: "0.8.0"
  replicas: 1
  ports:
    externalPort: 5656
    internalPort: 5656
  nodeSelector: {}
  tolerations: []
  affinity: {}

provisioner:
  image: "quay.io/openebs/openebs-k8s-provisioner"
  imageTag: "0.8.0"
  replicas: 1
  nodeSelector: {}
  tolerations: []
  affinity: {}

snapshotOperator:
  controller:
    image: "quay.io/openebs/snapshot-controller"
    imageTag: "0.8.0"
  provisioner:
    image: "quay.io/openebs/snapshot-provisioner"
    imageTag: "0.8.0"
  replicas: 1
  upgradeStrategy: "Recreate"
  nodeSelector: {}
  tolerations: []
  affinity: {}

ndm:
  image: "quay.io/openebs/node-disk-manager-amd64"
  imageTag: "v0.2.0"
  sparse:
    enabled: "true"
    path: "/var/openebs/sparse"
    size: "10737418240"
    count: "1"
  filters:
    excludeVendors: "CLOUDBYT,OpenEBS"
    excludePaths: "loop,fd0,sr0,/dev/ram,/dev/dm-,/dev/md"
  nodeSelector: {}

jiva:
  image: "quay.io/openebs/jiva"
  imageTag: "0.8.0"
  replicas: 3

cstor:
  pool:
    image: "quay.io/openebs/cstor-pool"
    imageTag: "0.8.0"
  poolMgmt:
    image: "quay.io/openebs/cstor-pool-mgmt"
    imageTag: "0.8.0"
  target:
    image: "quay.io/openebs/cstor-istgt"
    imageTag: "0.8.0"
  volumeMgmt:
    image: "quay.io/openebs/cstor-volume-mgmt"
    imageTag: "0.8.0"

policies:
  monitoring:
    enabled: true
    image: "quay.io/openebs/m-exporter"
    imageTag: "0.8.0"

analytics:
  enabled: true
  # Specify in hours the duration after which a ping event needs to be sent.
  pingInterval: "24h"

RAW_YAML
]
}

