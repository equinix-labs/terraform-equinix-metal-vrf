# Equinix Metal Virtual Routing and Forwarding (VRF)
[![Experimental](https://img.shields.io/badge/Stability-Experimental-red.svg)](https://github.com/equinix-labs/standards#about-uniform-standards)
[![terraform](https://github.com/equinix-labs/terraform-metal-vrf/actions/workflows/integration.yaml/badge.svg)](https://github.com/equinix-labs/terraform-metal-vrf/actions/workflows/integration.yaml)


# VRF deployment on Equinix Platform

This Terraform script provides VRF deployments on Equinix Metal platform where a Metal Gateway, a VRF and a number of metal nodes are deployed. The metal VRF is connected to a pair of customer colo edge devices via a pair of redundant Virtual Connections (VC) created in a redundant dedicated fabric port (see high-level diagram below). The VRF is used to establish BGP sessions with the colo network devices and advertise the specified network IPs to the colo.

<img width="1202" alt="Screen Shot 2022-05-28 at 4 33 37 PM" src="https://user-images.githubusercontent.com/46980377/170843873-bdd78ee1-4778-435b-be18-08b31ecc6f1b.png">

For information regarding Metal Gateway and VRF, please see the following Equinid Metal document - https://metal.equinix.com/developers/docs/networking/metal-gateway/, https://metal.equinix.com/developers/api/vrfs/ For the Layer-2 bonded mode, please see the following Equinix Metal document - https://metal.equinix.com/developers/docs/layer2-networking/layer2-mode/#pure-layer-2-modes   

For the Terraform resources used in this script, such as "equinix_metal_vrf" and other Equinix Metal resources, please see the terraform.io registry: https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/equinix_metal_vrf  

The Metal Gateway and the Metal nodes shared a single VLAN, the VLAN is hardcoded using 192.168.100.0/24 for IP assignments with Metal Gateway being assigned with 192.168.100.1, the first metal node being assigned with 192.168.100.2, the second metal node being assigned with 192.168.100.3 etc.  

In order to establish the BGP sessions, you'll need to setup the fabric virtual connections (VC) to your colo network devices and perform the BGP configurations too.

We recommend the following steps to be performed BEFORE runing this script:

Step 1 - Plan your setup, including your BGP neighbor IPs, network IPs (to be advertised via BGP) for metal gateway and metal nodes, Metal VRF ASN (use private ASN space, such as 65100), your network ASN, UUID of your dedicated Metal fabric port (obtaining it from Metal's portal), Metal project where you plan to deploy the VRF and Metal nodes etc. <br />

Step 2 - In Equinix Fabric portal, create a pair of redundant virtual connections (VC) using your dedicated fabric port to your colo network devices <br />

Step 3 - Perform BGP setups on your colo network edge devices. Perform server and VLAN setups on your colo side if needed <br />

Setp 4 - Setup the appropriate variable values in your terraform.tfvars file based on Step 1 <br />

Please note, DO NOT manually setup virtual connections (VC) using your Metal's dedicated fabric port via Metal's portal. This script will setup the VCs and BGP sessions etc. on Metal side. <br />

The following is the Terraform flow of this script:  

1.	Create metal nodes <br />
2.	Create a VLAN (or using an existing VLAN) <br />
3.	Attach the VLAN to instances (Metal nodes are setup as Layer 2 bonded mode) <br />
4.	Specify IP blocks to be used (both BGP IPs and Network IPs) <br />
5.	Create a VRF instance (with the Project ID, VLAN created, local ASN assigned, IP blocks etc.) <br />
6.	Allocate IPs for the gateway and its associated server nodes (from the IP pools in step 5) <br />
7.	Create a Metal Gateway instance using ip_reservation_id from step 6, & project ID, VLAN IDs etc. <br />
8.	Create and Attach VCs from your Metal's dedicated fabric ports to the VRF instance <br />

After the Metal nodes and VRF are sucessfully deployed, the following behaviors are expected:
1. A Metal node can reach to the metal gateway via the gateway's IP 192.168.100.1
2. Metal nodes can reach to each anoter via their IPs (192.168.100.x)
3. A Metal node can reach to the VRF's BGP neighbor IP (for example, 169.254.100.1)
4. A Metal node can reach to the colo device's BGP neighbor IP (for example, 169.254.100.2)
5. Metal nodes and your colo servers can reach to each other, if you have setup servers behind your colo network devices and advertise routes via the BGP sessions established between your network devices and the Metal VRF.

This repository is [Experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md) meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and we strongly encourage you to NOT use this in production.

## Install Terraform

Terraform is just a single binary.  Visit their [download page](https://www.terraform.io/downloads.html), choose your operating system, make the binary executable, and move it into your path.

Here is an example for **macOS**:

```bash
curl -LO https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_darwin_amd64.zip
unzip terraform_0.12.18_darwin_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
```

## Download this project

To download this project, run the following command:

```bash
git clone https://github.com/equinix-labs/terraform-metal-vrf.git
cd terraform-metal-vrf
```

## Initialize Terraform

Terraform uses modules to deploy infrastructure. In order to initialize the modules you simply run: `terraform init`. This should download modules into a hidden directory `.terraform`

## Modify your variables

See `variables.tf` for a description of each variable. You will need to set all the variables at a minimum in terraform.tfvars:

```
cp example.tfvars terraform.tfvars
vim terraform.tfvars
```

#### Note - Currently only Ubuntu has been tested

## Deploy terraform template

```bash
terraform apply --auto-approve
```

Once this is complete you should get output similar to this:

```console
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:

dedicated_port = [
  {
    "connection_id" = "06726413-c565-4173-82be-9a9562b9a69b"
    "description" = ""
    "facility" = "ny5"
    "id" = "06726413-c565-4173-82be-9a9562b9a69b"
    "metro" = "ny"
    "mode" = "standard"
    "name" = "NY-Metal-to-Fabric-Dedicated-Redundant-Port"
    "organization_id" = "e83e4455-e72a-4dc6-b48f-653b56db1939"
    "ports" = tolist([
      {
        "id" = "2a027f9f-dae6-454b-a783-2a25c678f506"
        "link_status" = "up"
        "name" = "NY-Metal-to-Fabric-Dedicated-Redundant-Port-primary"
        "role" = "primary"
        "speed" = 10000000000
        "status" = "active"
        "virtual_circuit_ids" = tolist([
          "6b52f881-eefe-4441-9613-40ff7dabeeca",
          "6319dbdf-7305-4c6f-a39c-411a94c8388c",
          "c35991a7-0fdc-4c15-b12b-8046c9258d15",
          "24b259ae-bba4-4d35-ac1f-978915a36aef",
        ])
      },
      {
        "id" = "963471e8-c815-4055-93b6-74092227d65c"
        "link_status" = "up"
        "name" = "NY-Metal-to-Fabric-Dedicated-Redundant-Port-secondary"
        "role" = "secondary"
        "speed" = 10000000000
        "status" = "active"
        "virtual_circuit_ids" = tolist([
          "52d176fe-7bbe-4c38-a487-73119f5c78d2",
          "9667bc63-2310-4d4e-81dc-e06979f6ebb0",
        ])
      },
    ])
    "project_id" = ""
    "redundancy" = "redundant"
    "speed" = 0
    "status" = "active"
    "tags" = tolist([])
    "token" = ""
    "type" = "dedicated"
  },
]
metal_gateway = [
  {
    "id" = "98cf7bb5-f7ae-45b6-ae71-733131042dcf"
    "ip_reservation_id" = "1ea66ec6-1325-4f94-b9b4-ae15c7668fe5"
    "private_ipv4_subnet_size" = 8
    "project_id" = "81666c08-3823-4180-832f-1ce1f13e1662"
    "state" = "ready"
    "vlan_id" = "6504eb92-5af7-4368-9cc9-a11b0f27cc62"
    "vrf_id" = "78034f87-5733-494f-b288-46c8a18da3f4"
  },
]

metal_vrf = [
  {
    "description" = "VRF with ASN 65100 and a pool of address space that includes a subnet for your BGP and subnets for each of your Metal Gateways"
    "id" = "78034f87-5733-494f-b288-46c8a18da3f4"
    "ip_ranges" = toset([
      "169.254.100.0/24",
      "192.168.100.0/24",
    ])
    "local_asn" = 65100
    "metro" = "ny"
    "name" = "my-vrf"
    "project_id" = "81666c08-3823-4180-832f-1ce1f13e1662"
    "timeouts" = null /* object */
  },
]
metrovlan_ids = [
  1006,
  1007,
]
server_name = [
  "mymetal-node-1",
  "mymetal-node-2",
]
ssh_private_key = "/Users/johndoe/myterraform/myvrf/Cloudinit/ssh-key-wieyh"
virtual_connection_primary = [
  {
    "connection_id" = "06726413-c565-4173-82be-9a9562b9a69b"
    "customer_ip" = "169.254.100.2"
    "description" = "Primary Virtual Circuit"
    "id" = "acb4f4cf-9c96-424c-bb6f-51bda36b17a5"
    "md5" = ""
    "metal_ip" = "169.254.100.1"
    "name" = "virtual_connection_pri"
    "nni_vlan" = 999
    "nni_vnid" = 999
    "peer_asn" = 100
    "port_id" = "2a027f9f-dae6-454b-a783-2a25c678f506"
    "project_id" = "81666c08-3823-4180-832f-1ce1f13e1662"
    "speed" = "0"
    "status" = "active"
    "subnet" = "169.254.100.0/30"
    "tags" = tolist(null) /* of string */
    "vlan_id" = tostring(null)
    "vnid" = 0
    "vrf_id" = "78034f87-5733-494f-b288-46c8a18da3f4"
  },
]
virtual_connection_secondary = [
  {
    "connection_id" = "06726413-c565-4173-82be-9a9562b9a69b"
    "customer_ip" = "169.254.100.10"
    "description" = "Secondary Virtual Circuit"
    "id" = "16db378e-923d-4c52-a8de-27b507e32dcc"
    "md5" = ""
    "metal_ip" = "169.254.100.9"
    "name" = "virtual_connection_sec"
    "nni_vlan" = 999
    "nni_vnid" = 999
    "peer_asn" = 100
    "port_id" = "963471e8-c815-4055-93b6-74092227d65c"
    "project_id" = "81666c08-3823-4180-832f-1ce1f13e1662"
    "speed" = "0"
    "status" = "active"
    "subnet" = "169.254.100.8/30"
    "tags" = tolist(null) /* of string */
    "vlan_id" = tostring(null)
    "vnid" = 0
    "vrf_id" = "78034f87-5733-494f-b288-46c8a18da3f4"
  },
]

```
