#!/bin/bash

## change the hostname
hostname mqtthost
## restart docker
sudo service docker restart

echo "Configuring adapter for subnet A"
echo "Creating MacVlan adapter"
ip link add macvlanA link eth0 type macvlan mode bridge
echo "Adapter successfully created"
printf "\nLinking MacVlan adapter to ip address %s\n" "192.168.28.1/24"
ip address add dev macvlanA 192.168.28.1/24
echo "Enabling adapter"
ip link set macvlanA up
echo "Adapter enabled"
echo -e "Configured adapter for subnet A \n"

echo "Configuring adapter for subnet C"
echo "Creating MacVlan adapter"
ip link add macvlanC link eth0 type macvlan mode bridge
echo "Adapter successfully created"
printf "\nLinking MacVlan adapter to ip address %s\n" "192.168.4.1/24"
ip address add dev macvlanC 192.168.4.1/24
echo "Enabling adapter"
ip link set macvlanC up
echo "Adapter enabled"
echo -e "Configured adapter for subnet C\n"

echo "Loading mqqt broker\n"
docker pull eclipse-mosquitto

echo "Adding volume folder"
mkdir -p mosquitto/config

echo "Creating broker config"
touch mosquitto/config/mosquitto.conf

cat << EOF > mosquitto/config/mosquitto.conf
listener 1883
allow_anonymous true
EOF

echo "Starting broker"
docker run -v $PWD/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -p 1883:1883 --name broker --rm eclipse-mosquitto
