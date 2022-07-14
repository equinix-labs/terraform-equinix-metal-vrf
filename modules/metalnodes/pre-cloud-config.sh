#!/usr/bin/env bash
sed -i -E -e '/^datasource_list:.*/s/.*/datasource_list: [NoCloud]/' /etc/cloud/cloud.cfg
rm /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
rm /etc/network/interfaces
rm /etc/networks
apt purge -y ifupdown

