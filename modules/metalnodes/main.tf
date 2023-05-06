
# define provider version and Metal Token
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    equinix = {
      source = "equinix/equinix"
      version = "~> 1.14"
    }
  }
  provider_meta "equinix" {
    module_name = "equinix-metal-vrf/metalnodes"
  }
}

variable "project_id" {}
variable "node_count" {}
variable "plan" {}
variable "metro" {}
variable "operating_system" {}
variable "metal_vlan" {}
variable "ssh_key" {}

# create metal nodes
resource "equinix_metal_device" "metal_nodes" {
  count            = var.node_count
  hostname         = format("mymetal-node-%d", count.index + 1)
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.project_id
  user_data        = data.cloudinit_config.config[count.index].rendered
  depends_on       = [var.metal_vlan, var.ssh_key]
}

data "cloudinit_config" "config" {
  count         = var.node_count
  gzip          = false # not supported on Equinix Metal
  base64_encode = false # not supported on Equinix Metal

  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/pre-cloud-config.sh")
  }

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-config.cfg", {
    VLAN_ID_0  = var.metal_vlan[0].vxlan
    VLAN_ID_1  = var.metal_vlan[1].vxlan
    LAST_DIGIT = count.index + 2
    })
  }
}

## Example for executing scripts on metal nodes
resource "null_resource" "ssh-after-deploy" {
  count      = var.node_count
  depends_on = [equinix_metal_port.port]
  connection {
    host        = equinix_metal_device.metal_nodes[count.index].access_public_ipv4
    type        = "ssh"
    user        = "root"
    private_key = var.ssh_key
  }
}
## put metal nodes in layer2 bonded mode and attach metro vlan to the nodes
resource "equinix_metal_port" "port" {
  count = var.node_count
  port_id  = [for p in equinix_metal_device.metal_nodes[count.index].ports : p.id if p.name == "bond0"][0]
  layer2   = true
  bonded   = true
  vlan_ids = var.metal_vlan.*.id
  depends_on = [equinix_metal_device.metal_nodes]
}

