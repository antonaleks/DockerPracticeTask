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

touch mosquitto.conf
cat << EOF > mosquitto.conf 
listener 1883
allow_anonymous true
EOF

mkdir -p ./mosquitto/config

mv -v ~/mosquitto.conf ~/mosquitto/config/

docker pull eclipse-mosquitto

docker run -v $PWD/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -p 1883:1883 --name broker --rm eclipse-mosquitto