auth_token         = "your_metal_api_token"
project_id         = "your_metal_project_id"
metro              = "ny"
plan               = "c3.small.x86"
operating_system   = "ubuntu_20_04"
server_count       = 2
nni_vlan           = 999
dedicated_port_id  = "your_metal_dedicated_port_UUID"
ip_ranges          = ["169.254.100.0/24", "192.168.100.0/24", "192.168.200.0/24"]
## the following have to match what configred in the customer router
bgp_peer_subnet    = "169.254.100.0/30"
metal_bgp_ip       = "169.254.100.1"
customer_bgp_ip    = "169.254.100.2"
