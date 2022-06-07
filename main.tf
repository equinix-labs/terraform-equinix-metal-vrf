# define provider version and Metal Token
terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
      version = "= 1.6.0-alpha.3"
    }
  }
}
provider "equinix" {
  auth_token = var.auth_token
}


# allocate a metal's metro vlans for the project

resource "equinix_metal_vlan" "metro_vlan" {
  count       = var.vlan_count
  description = "Metal's metro VLAN"
  metro       = var.metro
  project_id  = var.project_id
}


# deploy Metal server(s)

resource "equinix_metal_device" "metal_node" {
  count            = var.server_count
  hostname         = format("metal-node-%d", count.index + 1)
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.project_id
}

 ## execute script files in metal_node in order to attach metro VLANs to metal nodes
resource "null_resource" "configure-server-network" {
    count         =  var.server_count
    connection {
      host        = equinix_metal_device.metal_node[count.index].access_public_ipv4
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }

    provisioner "file" {
      source      = "${path.module}/server.sh"
      destination = "/root/network-configurator.script"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /root/network-configurator.script",
        "/root/network-configurator.script ${equinix_metal_vlan.metro_vlan[0].vxlan} ${count.index}",
        "sudo systemctl restart networking"
    ]
    on_failure = continue
    }

    ## clean-up the network configuration file
    provisioner "remote-exec" {
    inline = [
        "rm -f /root/network-configurator.script"
    ]
    }
}

# Attach metro VLANs to metal_node. To put the node in hybrid-bonded mode, leave the node in default L3 mode and attach a VLAN to bond0

resource "equinix_metal_port_vlan_attachment" "attach-vlan-to-node" {
  count     =  var.server_count
  device_id =  equinix_metal_device.metal_node[count.index].id
  port_name = "bond0"
  force_bond = true
  vlan_vnid  = equinix_metal_vlan.metro_vlan[0].vxlan
  depends_on = [null_resource.configure-server-network]
}

# create a VRF in the same project where the nodes and VLANs are deployed and specify the subnet(s) you want 
# to reserve for BGP IPs and the IPs you want to advertise via the VRF (for example "169.254.100.0/29", "192.168.100.0/24", "192.168.200.0/24")
# where, "169.254.100.0/29" are assigned to your VRF and its remote peer's BGP speakers, "192.168.100.0/24" will be assigned to gateway-1 and its associated metal nodes, 
# "192.168.200.0/24" will be assigned to gateway-2 and its associated metal nodes

resource "equinix_metal_vrf" "my_vrf" {
   description = "VRF with ASN 65100 and a pool of address space that includes a subnet for your BGP and subnets for each of your Metal Gateways"
   name        = "my-vrf"
   metro       = var.metro
   project_id  = var.project_id
   local_asn   = var.metal_asn
   ip_ranges   = var.ip_ranges
}

# Create an IP reservation from the VRF IP pools and assign them to a Metal Gateway resources. 
# The Gateway will be assigned the first address in the block.
# in this case the GW will be assigned 192.168.100.1
# Note, you'll need at least one gateway for each subnet you reserved in resource "equinix_metal_vrf" 

resource "equinix_metal_reserved_ip_block" "my_gateway_ip" {
    description = "Reserved gateway IP block (192.168.100.0/24) taken from one of the ranges in the VRF's pool of address space ip_ranges. "
    project_id  = var.project_id
    metro       = var.metro
    type        = "vrf"
    vrf_id      = equinix_metal_vrf.my_vrf.id
    cidr        = 29
    network     = "192.168.100.0"
}
# Create a gateway in my current project and assign the reserved IP and the metal's metro vlan to the gateway
# please notice "vlan_id" is the Metro VLAN's UUID

resource "equinix_metal_gateway" "my_gateway" {
    project_id        = var.project_id
    vlan_id           = equinix_metal_vlan.metro_vlan[0].id
    ip_reservation_id = equinix_metal_reserved_ip_block.my_gateway_ip.id
}

# The "dedicated_port_id" is the UUID of your dedicated port obtained in Metal's Portal

data "equinix_metal_connection" "dedicated_port" {
    connection_id = var.dedicated_port_id
}

# Create a VC (Virtual Connection) or a pair of VCs for HA (Primary and Secondary respectively) connecting VRF with the far-end (customer end). "metal_ip" is the BGP Speaker IP address of the VRF which will default to the first usable IP in the subnet. It peers with the "customer_ip".
# which is the BGP Speaker IP address which the Metal VRF will peer with. 
# After the VC is succsfuly created, there will be no metro VLAN associated with the VC and the VC status will be "Active" in Metal's portal
# This resource will ONLY create the connection on the Metal's portal. You'll need to setup the VC in fabric portal using the same "nni_vlan" first

resource "equinix_metal_virtual_circuit" "my_vc_pri" {
    name          = "virtual_connection_pri"
    description   = "Primary Virtual Circuit"
    connection_id = data.equinix_metal_connection.dedicated_port.id
    project_id    = var.project_id
    port_id       = data.equinix_metal_connection.dedicated_port.ports[0].id
    nni_vlan      = var.nni_vlan
    vrf_id        = equinix_metal_vrf.my_vrf.id
    peer_asn      = var.customer_asn
    subnet        = var.bgp_peer_subnet_pri
    metal_ip      = var.metal_bgp_ip_pri
    customer_ip   = var.customer_bgp_ip_pri
} 

resource "equinix_metal_virtual_circuit" "my_vc_sec" {
    name          = "virtual_connection_sec"
    description   = "Secondary Virtual Circuit"
    connection_id = data.equinix_metal_connection.dedicated_port.id
    project_id    = var.project_id
    port_id       = data.equinix_metal_connection.dedicated_port.ports[1].id
    vrf_id        = equinix_metal_vrf.my_vrf.id
    nni_vlan      = var.nni_vlan
    peer_asn      = var.customer_asn
    subnet        = var.bgp_peer_subnet_sec
    metal_ip      = var.metal_bgp_ip_sec
    customer_ip   = var.customer_bgp_ip_sec
}
