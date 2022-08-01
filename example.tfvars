## Please note:
## 1. your metro, such as "ny" has to be the metro where your dedicated metal fabric port is located
## 2. nni_vlan need to be the same as you specified in your VC setup via Fabric Portal
## 3. in the following example, 169.254.100.0/24 is the BGP IPs (or BGP neighbors' IP), 192.168.100.0/24 is the network IP prefix you plan to advertise via BGP sessions

auth_token         = "your_metal_api_token"
project_id         = "your_metal_project_id"
metro              = "ny"
plan               = "c3.small.x86"
operating_system   = "ubuntu_20_04"
server_count       = 2
vlan_count         = 2
nni_vlan           = 999
dedicated_port_id  = "your_metal_dedicated_port_UUID"
ip_ranges          = ["169.254.100.0/24", "192.168.100.0/24"]
