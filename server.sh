#!/bin/bash
set +e
set -x

VLAN_ID=$1
BACKEND_COUNT=$2

apt update
apt install vlan
modprobe 8021q
echo "8021q">>/etc/modules

LAST_DIGI=$((2 + $BACKEND_COUNT))
echo "
auto bond0.$VLAN_ID
  iface bond0.$VLAN_ID inet static
  pre-up sleep 5
  address 192.168.100.$LAST_DIGI
  netmask 255.255.255.0
  vlan-raw-device bond0
  post-up route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.168.100.1">>/etc/network/interfaces
