#!/bin/bash

while true; do
	echo 'Waiting for MySQL to start.'
	echo '' | nc -w 1 $MYSQL_IP 3306 && break
	sleep 1
done
echo

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export IP_ADDR=$(awk 'END{print $1}' /etc/hosts)
export IF_NAME=$(ip r | awk '/default/ { print $5 }')

python3 /mnt/pgw/tun_if.py --tun_ifname ogstun --ipv4_range 192.168.100.0/24 --ipv6_range fd84:6aea:c36e:2b69::/64
python3 /mnt/pgw/tun_if.py --tun_ifname ogstun2 --ipv4_range 192.168.101.0/24 --ipv6_range fd1f:76f3:da9b:0101::/64

CONF=/open5gs/install/etc/open5gs/pgw.yaml
cp /mnt/pgw/pgw.yaml ${CONF}

sed -i 's|PGW_IP|'$IP_ADDR'|g' ${CONF}
sed -i 's|PGW_IF|'$IF_NAME'|g' ${CONF}
sed -i 's|PCRF_IP|'$PCRF_IP'|g' ${CONF}
sed -i 's|DNS_IP|'$DNS_IP'|g' ${CONF}
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' ${CONF}

sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/kamailio_pcscf/kamailio_pcscf.cfg
sed -i 's|RTPENGINE_IP|'$RTPENGINE_IP'|g' /etc/kamailio_pcscf/kamailio_pcscf.cfg
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/kamailio_pcscf/pcscf.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_pcscf/pcscf.cfg
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/kamailio_pcscf/pcscf.xml


/open5gs/install/bin/open5gs-pgwd &
sleep 10
/etc/init.d/kamailio_pcscf debug
