resource "helm_release" "rancher" {
  depends_on = ["helm_release.cert-manager"]
  namespace  = "cattle-system"
  name       = "rancher"
  repository = "${helm_repository.rancher-stable.metadata.0.name}"
  chart      = "rancher"
  values = [ <<RAW_YAML

hostname: ${var.rancher_hostname}

ingress:
  tls:
    source: letsEncrypt

letsEncrypt:
  email: ${var.letsencrypt_email}

RAW_YAML
]
}
