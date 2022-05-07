#!/bin/bash
VLAN_ID=$1
apt update
apt install vlan
modprobe 8021q
echo "8021q">>/etc/modules

echo "
auto bond0.$VLAN_ID
  iface bond0.$VLAN_ID inet static
  pre-up sleep 5
  address 192.168.100.5
  netmask 255.255.255.254
  vlan-raw-device bond0">>/etc/network/interfaces
