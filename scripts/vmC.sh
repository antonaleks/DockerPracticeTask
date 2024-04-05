#!/bin/bash

## change the hostname
hostname serverhost
## restart docker
sudo service docker restart

echo "Configuring adapter for subnet C"
echo "Creating MacVlan adapter"
ip link add macvlan1 link eth0 type macvlan mode bridge
echo "Adapter successfully created"

printf "\nLinking MacVlan adapter to ip address %s\n" "192.168.4.100/24"
ip address add dev macvlan1 192.168.4.100/24
echo "Enabling adapter"
ip link set macvlan1 up
echo "Adapter enabled"

echo "Routing through %s to %s" "192.168.28.0/24" "192.168.4.1"
ip route add 192.168.28.0/24 via 192.168.4.1

echo "Creating containers config"
touch docker-compose.yml

cat << EOF > docker-compose.yml
version: "3"
services:
  telegraf:
    image: telegraf
    container_name: telegraf
    volumes:
      - ./telegraf:/etc/telegraf:ro
    restart: unless-stopped
    networks:
      - server-net

networks:
  server-net: {}
EOF


echo "Starting server environment"
docker compose up

# while ! timeout 1 ping -c 1 -n 192.168.28.10:5000 &>/dev/null; do
# 	printf "%s\n" "Waiting for server response"
# done

# printf "Sending %s request" "GET"
# curl http://192.168.28.10:5000/users

# printf "Sending %s request" "POST"
# curl -X POST http://192.168.28.10:5000/users?user=Alexander
# curl -X POST http://192.168.28.10:5000/users?user=Alexey
# curl -X POST http://192.168.28.10:5000/users?user=Evgeniy
# curl -X POST http://192.168.28.10:5000/users?user=Polina

# printf "Sending %s request" "PUT"
# curl -X PUT http://192.168.28.10:5000/users?user=Polina
# curl -X PUT http://192.168.28.10:5000/users?user=Polina
# curl -X PUT http://192.168.28.10:5000/users?user=Polina
# curl -X PUT http://192.168.28.10:5000/users?user=Alexander

# printf "All users with GET request"
# curl http://192.168.28.10:5000/users
