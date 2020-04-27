#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export IP_ADDR=$(awk 'END{print $1}' /etc/hosts)
export IF_NAME=$(ip r | awk '/default/ { print $5 }')

# python3 /mnt/pgw/tun_if.py --tun_ifname ogstun --ipv4_range 192.168.100.0/24 --ipv6_range fd84:6aea:c36e:2b69::/64
# python3 /mnt/pgw/tun_if.py --tun_ifname ogstun2 --ipv4_range 192.168.101.0/24 --ipv6_range fd1f:76f3:da9b:0101::/64

ip tuntap add name ogstun mode tun
ip addr add 192.168.100.1/24 dev ogstun
ip addr add fd84:6aea:c36e:2b69:0000:0000:0000:0001/64 dev ogstun
ip link set ogstun mtu 1400
ip link set ogstun up
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -o ogstun -j MASQUERADE
ip6tables -t nat -A POSTROUTING -s fd84:6aea:c36e:2b69::/64 ! -o ogstun -j MASQUERADE
iptables -A INPUT -i ogstun -j ACCEPT
ip6tables -A INPUT -i ogstun -j ACCEPT

ip tuntap add name ogstun2 mode tun
ip addr add 192.168.101.1/24 dev ogstun2
ip addr add fd1f:76f3:da9b:0101:0000:0000:0000:0001/64 dev ogstun2
ip link set ogstun2 mtu 1400
ip link set ogstun2 up
iptables -A INPUT -i ogstun2 -j ACCEPT
ip6tables -A INPUT -i ogstun2 -j ACCEPT

cp /mnt/pgw/pgw.yaml install/etc/open5gs
sed -i 's|PGW_IP|'$IP_ADDR'|g' install/etc/open5gs/pgw.yaml
sed -i 's|PGW_IF|'$IF_NAME'|g' install/etc/open5gs/pgw.yaml
sed -i 's|PCRF_IP|'$PCRF_IP'|g' install/etc/open5gs/pgw.yaml
sed -i 's|DNS_IP|'$DNS_IP'|g' install/etc/open5gs/pgw.yaml
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' install/etc/open5gs/pgw.yaml
