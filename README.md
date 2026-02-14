# VSC Server Infrastructure

This repository contains the Terraform configuration for deploying a VSC (Visual Studio Code) server on Oracle Cloud Infrastructure (OCI) using Ampere A1 Compute instances.

## Credits

This project leverages the excellent [terraform-oci-ampere-a1](https://github.com/AmpereComputing/terraform-oci-ampere-a1) module provided by Ampere Computing.

## Prerequisites

- OCI Account and API keys
- Terraform installed locally
- SSH key pair for instance access

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Configure your variables in `terraform.tfvars`:
   ```hcl
   tenancy_ocid     = "ocid1.tenancy.oc1..xxxx"
   user_ocid        = "ocid1.user.oc1..xxxx"
   fingerprint      = "xx:xx:xx..."
   private_key_path = "./oci-id_rsa"
   region           = "eu-milan-1"
   ```

3. Deploy the infrastructure:
   ```bash
   terraform apply
   ```

## License

Refer to the license of the upstream [Ampere OCI module](https://github.com/AmpereComputing/terraform-oci-ampere-a1).
