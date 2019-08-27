resource "helm_release" "cert-manager" {
  depends_on = ["null_resource.helm_init"]
  namespace  = "kube-system"
  name       = "cert-manager"
  repository = "${helm_repository.stable.metadata.0.name}"
  chart      = "cert-manager"
  values = [ <<RAW_YAML

ingressShim:
  defaultIssuerName: letsencrypt-prod
  defaultIssuerKind: ClusterIssuer

RAW_YAML
]
}

resource "null_resource" "cert-manager" {
  depends_on = ["helm_release.cert-manager"]
  provisioner "local-exec" {
    command = <<EOT
export KUBECONFIG=${local_file.kube_cluster_yaml.filename}
# Wait for cert-manager
kubectl rollout status -w deployment/cert-manager --namespace=kube-system
cat <<EOF | kubectl create -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: kube-system
spec:
  acme:
    email: ${var.letsencrypt_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    http01: {}
EOF
EOT
  }
}
