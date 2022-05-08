output "metrovlan_ids" {
  value = equinix_metal_vlan.metro_vlan.*.vxlan
  description = "Your vlan for metal gateway:"
}

output "server_name" {
  value       = equinix_metal_device.metal_node[*].hostname
  description = "Your metal node's hostname:"
}

output "metal_node_ip" {
  value       = equinix_metal_device.metal_node[*].access_public_ipv4
  description = "Your metal node's IP addresses:"
}

output "metal_vrf" {
  value       = equinix_metal_vrf.my_vrf.*
  description = "My VRF Information:"
}

output "metal_gateway" {
  value       = equinix_metal_gateway.my_gateway.*
  description = "My Gateway Information:"
}

 output "dedicated_port" {
  value       = data.equinix_metal_connection.dedicated_port.*
  description = "My dedicated port for VRF:"
}

 output "virtial_connection" {
  value       = equinix_metal_virtual_circuit.my_vc.*
  description = "My VC connecting VRF information:"
} 
