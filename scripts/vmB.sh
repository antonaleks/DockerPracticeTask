#!/bin/bash
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

echo "Loading resources"
git clone https://github.com/AlexanderSynex/DockerPractice.git
