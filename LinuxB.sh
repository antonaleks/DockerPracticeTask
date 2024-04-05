#!/bin/bash
# Linux B

echo -e "Starting the first MACVLAN installation\n"
ip link add macvlan1 link eth0 type macvlan mode bridge
ip address add dev macvlan1 192.168.14.1/24
ip link set macvlan1 up
echo -e "Ending the first MACVLAN installation\n\n"

echo -e "Starting the second MACVLAN installation\n"
ip link add macvlan2 link eth0 type macvlan mode bridge
ip addres add dev macvlan2 192.168.11.1/24
ip link set macvlan2 up
echo -e "Ending the second MACVLAN installation\n\n"

echo -e "Creating mosquitto.conf\n"

touch mosquitto.conf
cat << EOF > mosquitto.conf 
listener 1883
allow_anonymous true
EOF

mkdir -p ./mosquitto/config

echo -e "Changing the directory for a file  mosquitto.conf/n"
mv -v ~/mosquitto.conf ~/mosquitto/config/

echo -e "Strting pull eclipse-mosquitto\n"

iptables -P INPUT ACCEPT

docker pull eclipse-mosquitto

echo -e "Deny incoming traffic from all ports\n"
iptables -P INPUT DROP

echo -e "Set exception for incoming traffic from port 1883\n"

iptables -A INPUT -i eth0 -p tcp --dport 1883 -j ACCEPT

echo -e "Run docker is named broker\n"
docker run -v $PWD/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -p 1883:1883 --name broker --rm eclipse-mosquitto

