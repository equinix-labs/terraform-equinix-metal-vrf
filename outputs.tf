output "metrovlan_ids" {
  value       = equinix_metal_vlan.metro_vlan.*.vxlan
  description = "Your vlan for metal gateway:"
}

output "server_name" {
  value       = module.metal_nodes.node_names
  description = "Your metal node's hostname:"
}

output "metal_node_ip" {
  value       = module.metal_nodes.nodes_public_ipv4
  description = "Your metal node's IP addresses:"
}

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

output "dedicated_port" {
  value       = data.equinix_metal_connection.dedicated_port.*
  description = "The dedicated port for VRF:"
}

output "virtual_connection_primary" {
  value       = equinix_metal_virtual_circuit.my_vc_pri.*
  description = "Information of Primary VC connecting to VRF:"
}

output "virtual_connection_secondary" {
  value       = equinix_metal_virtual_circuit.my_vc_sec.*
  description = "Information of Secondary VC connecting to VRF:"
}
