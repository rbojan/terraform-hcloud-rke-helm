provider "helm" {
  kubernetes {
    config_path = "${local_file.kube_cluster_yaml.filename}"
  }
}

resource "helm_repository" "stable" {
  depends_on = ["null_resource.helm_init"]
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_repository" "rancher-stable" {
  depends_on = ["null_resource.helm_init"]
  name = "rancher-stable"
  url  = "https://releases.rancher.com/server-charts/stable"
}