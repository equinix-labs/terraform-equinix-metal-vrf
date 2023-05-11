terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
      version = "~> 1.14"
    }
  }
  required_version = ">= 1.0.0"
  provider_meta "equinix" {
    module_name = "equinix-metal-vrf/ssh"
  }
}

#provider "equinix" {
#  auth_token = var.auth_token
#}

variable "project_id" {
  description = "Equinix Metal Project ID where the SSH Key should be added"
}

locals {
  ssh_key_name = format("ssh-key-%s", random_string.ssh_unique.result)
  ssh_key_file = abspath("${path.root}/${local.ssh_key_name}")
}

resource "random_string" "ssh_unique" {
  length  = 5
  special = false
  upper   = false
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "equinix_metal_ssh_key" "ssh_pub_key" {
  name       = local.ssh_key_name
  public_key = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
}

resource "local_file" "project_private_key_pem" {
  content         = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  filename        = local.ssh_key_file
  file_permission = "0600"
}

output "ssh_private_key" {
  value = local.ssh_key_file
}

output "ssh_private_key_contents" {
  value = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  sensitive = true
}
