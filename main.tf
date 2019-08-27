#
# Provider config
#
variable "hcloud_token" {}

provider "hcloud" {
  token = "${var.hcloud_token}"
}


#
# Variables
#
variable "ssh_public_key" {
  default = "~/terraform-hcloud-rke-helm/.ssh/id_rsa.pub"
}
variable "server_name" {
	default = "rancher"
}
variable "server_count" {
	default = "3"
}
variable "server_type" {
	default = "cx21"
	# default = "cx21 # 2vCPU 4GBRAM 40GBSSD 20TBTRAFFIC
}
variable "letsencrypt_email" {
  default = "you@example.com"
}
variable "rancher_hostname" {
  default = "rancher.you.example.com"
}


#
# Resources
#
resource "hcloud_ssh_key" "this" {
  name = "terraform-hcloud-rancher"
  public_key = "${file(var.ssh_public_key)}"
}

data "template_file" "this" {
  template = "${file("${path.module}/files/init.tpl")}"

  vars {
    DOCKER_VERSION = "17.03.2"
  }
}

resource "hcloud_server" "this" {
  count = "${var.server_count}"

  name        = "${format("%s-%d", var.server_name, count.index)}"
  image       = "ubuntu-16.04"
  server_type = "${var.server_type}"

  ssh_keys    = ["${hcloud_ssh_key.this.id}"]

  # user_data = "${data.template_file.this.rendered}"

  provisioner "file" {
    connection {
      private_key = "${file("${path.root}/.ssh/id_rsa")}"
    }
    content      = "${data.template_file.this.rendered}"
    destination  = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    connection {
      private_key = "${file("${path.root}/.ssh/id_rsa")}"
    }
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh",
    ]
  }
}

data "rke_node_parameter" "this" {
  count   = "${var.server_count}"

  address      = "${element(hcloud_server.this.*.ipv4_address, count.index)}"
  user         = "root"
  ssh_key_path = "${path.root}/.ssh/id_rsa"

  role = ["controlplane", "worker", "etcd"]
}

resource "rke_cluster" "this" {
  nodes_conf = ["${data.rke_node_parameter.this.*.json}"]
}

resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/rke_kube_config_cluster.yml"
  content = "${rke_cluster.this.kube_config_yaml}"
}

resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = <<EOT
export KUBECONFIG=${local_file.kube_cluster_yaml.filename}
# RBAC for helm
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF
helm init --service-account tiller
# Wait for tiller-deploy
kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system
EOT
  }
}


#
# Outputs
#
output "ipv4_addresses" {
  value = ["${hcloud_server.this.*.ipv4_address}"]
}
