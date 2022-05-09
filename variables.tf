variable "auth_token" {
  type        = string
  description = "Your Equinix Metal API key (https://console.equinix.com/users/-/api-keys)"
  sensitive   = true
}

variable "project_id" {
  type        = string
  description = "Your Equinix Metal project ID, where you want to deploy your nodes to"
}

variable "plan" {
  type        = string
  description = "Metal server type you plan to deploy"
  default     = "c3.small.x86"
}

variable "operating_system" {
  type        = string
  description = "OS you want to deploy"
  default     = "ubuntu_20_04"
}

variable "metro" {
  type        = string
  description = "Metal's Metro location you want to deploy your servers to"
  default     = "ny"
}

variable "server_count" {
  type        = number
  description = "numbers of backend nodes you want to deploy"
  default     = 1
}

variable "vlan_count" {
  type        = number
  description = "Metal's Metro VLAN"
  default     = 1
}

variable "metal_asn" {
  type        = number
  description = "Metal's local ASN"
  default     = 65100
}

variable "customer_asn" {
  type        = number
  description = "Metal customer's ASN peering with Metal"
  default     = 100
}

variable "bgp_peer_subnet" {
  type         = string
  description  = "BGP peering subnet"
  default      = "169.254.100.0/30"
}

variable "metal_bgp_ip" {
  type         = string
  description  = "Metal's local BGP IP peering with customer's BGP IP"
  default      = "169.254.100.1"
}

variable "customer_bgp_ip" {
  type         = string
  description  = "Customer's BGP IP Peering with metal's BGP IP"
  default      = "169.254.100.2"
}
variable "gateway_count" {
  type        = number
  description = "number of Metal Gateway"
  default     = 1
}

variable "dedicated_port_id" {
  type        = string
  description = "Your Metal's dedicated fabric port's UUID. You can retrieve the UUID from Metal's portal"
  default     = "123456789"
}

variable "nni_vlan" {
  type        = number
  description = "Your fabric virtual circuit's NNI VLAN connecting to your VRF"
  default     = 999
}

variable "ip_ranges" {
  type        = list
  description = "Your reserved IP ranges"
}
