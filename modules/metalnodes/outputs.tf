## the "metal_nodes" is used in main outputs.tf files

output "node_names" {
  value       = equinix_metal_device.metal_nodes.*.hostname
  description = "Your metal nodes:"
}

output "nodes_public_ipv4" {
  value       = equinix_metal_device.metal_nodes.*.access_public_ipv4
  description = "Your metal nodes' IP:"
}
