# terraform-hcloud-rke-helm

Terraform scripts to deploy a Kubernetes Cluster via rke on Hetzner Cloud with cert-manager, Rancher and OpenEBS included.

## Usage

````
export TF_VAR_hcloud_token=TOKEN

terraform init
terraform plan
terraform apply
````
