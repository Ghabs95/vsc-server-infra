# Example of Ampere A1 running Ubuntu 24.04 on OCI using this module
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {
  default = "eu-milan-1"
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

locals {
  cloud_init_template_path = "${path.cwd}/cloud-init.yaml.tpl"
  webhook_allowed_cidrs = [
    "95.248.208.163/32",
    "192.30.252.0/22",
    "185.199.108.0/22",
    "140.82.112.0/20",
    "143.55.64.0/20",
    "2a0a:a440::/29",
    "2606:50c0::/32",
  ]
}
module "oci-ampere-a1" {
  source           = "github.com/amperecomputing/terraform-oci-ampere-a1"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  # Optional
  # oci_vcn_cidr_block       = "10.2.0.0/16"
  # oci_vcn_cidr_subnet      = "10.2.1.0/24"
  oci_os_image             = "ubuntu2404"
  instance_prefix          = "ampere-a1-ubuntu-2404"
  oci_vm_count             = "1"
  ampere_a1_vm_memory      = "24"
  ampere_a1_cpu_core_count = "4"
  cloud_init_template_file = local.cloud_init_template_path
}

output "oci_ampere_a1_private_ips" {
  value = module.oci-ampere-a1.ampere_a1_private_ips
}
output "oci_ampere_a1_public_ips" {
  value = module.oci-ampere-a1.ampere_a1_public_ips
}
output "webhook_url" {
  value = "http://${module.oci-ampere-a1.ampere_a1_public_ips[0][0]}/webhook"
}
output "webhook_url_port8081" {
  value = "http://${module.oci-ampere-a1.ampere_a1_public_ips[0][0]}:8081/webhook"
}

resource "null_resource" "lifecycle_lock" {
  provisioner "local-exec" {
    command = "echo 'Lifecycle lock active'"
  }
  lifecycle {
    prevent_destroy = true
  }
}
