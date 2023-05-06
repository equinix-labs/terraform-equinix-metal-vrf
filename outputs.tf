output "metrovlan_ids" {
  value       = equinix_metal_vlan.metro_vlan.*.vxlan
  description = "Your vlan for metal gateway:"
}

output "server_name" {
  value       = module.equinix_metal_nodes.node_names
  description = "Your metal node's hostname:"
}

/* Don't output metal nodes' IPs in layer2 mode
output "metal_node_ip" {
  value       = module.equinix_metal_nodes.nodes_public_ipv4
  description = "Your metal node's IP addresses:"
}
*/

output "ssh_private_key" {
  value       = module.ssh.ssh_private_key
  description = "SSH Key for root access to nodes"
}

output "metal_vrf" {
  value       = equinix_metal_vrf.my_vrf.*
  description = "The VRF Information:"
}

output "metal_gateway" {
  value       = equinix_metal_gateway.my_gateway.*
  description = "The Gateway Information:"
}
output "dedicated_ports" {
  value = {
    port_id    = data.equinix_metal_connection.dedicated_port.id,
    name       = data.equinix_metal_connection.dedicated_port.name,
    metro      = data.equinix_metal_connection.dedicated_port.metro,
    redundancy = data.equinix_metal_connection.dedicated_port.redundancy
  }
  description = "The dedicated port information for VRF"
}

output "virtual_connection_primary" {
  value = {
    vc_id    = equinix_metal_virtual_circuit.my_vc_pri.id,
    name     = equinix_metal_virtual_circuit.my_vc_pri.name,
    nni_vlan = equinix_metal_virtual_circuit.my_vc_pri.nni_vlan,
    peer_asn = equinix_metal_virtual_circuit.my_vc_pri.peer_asn,
    peer_ip  = equinix_metal_virtual_circuit.my_vc_pri.customer_ip,
    metal_ip = equinix_metal_virtual_circuit.my_vc_pri.metal_ip
  }
  description = "Information of Primary VC connecting to VRF"
}

output "virtual_connection_secondary" {
  value = {
    vc_id    = equinix_metal_virtual_circuit.my_vc_sec.id,
    name     = equinix_metal_virtual_circuit.my_vc_sec.name,
    nni_vlan = equinix_metal_virtual_circuit.my_vc_sec.nni_vlan,
    peer_asn = equinix_metal_virtual_circuit.my_vc_sec.peer_asn,
    peer_ip  = equinix_metal_virtual_circuit.my_vc_sec.customer_ip,
    metal_ip = equinix_metal_virtual_circuit.my_vc_sec.metal_ip
  }
  description = "Information of Secondary VC connecting to VRF"
}

