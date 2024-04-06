#! /bin/bash
# Linux A

echo -e "Starting the MACVLAN installation\n"
ip link add macvlan1 link eth0 type macvlan mode bridge
ip address add dev macvlan1 192.168.14.10/24
ip link set macvlan1 up

echo -e "Ending the MACVLAN installation\n\n"

echo -e "Routing configuration FROM Linux A to Linux C \n\n"
ip route add 192.168.11.0/24 via 192.168.14.1

echo -e "Setting the ip to Linux B\n"
export IP_B=192.168.14.1

echo -e "Creating multi-container\n"

touch docker-compose.yml 
cat << EOF > docker-compose.yml 

version: "3"

services:
  temp_sensor:
    image: polinazhirakova/data-simulator
    environment:
      - SIM_HOST=${IP_B}
      - SIM_NAME=TEMP1
      - SIM_PERIOD=3
      - SIM_TYPE=temperature
  pressure_sensor:
    image: polinazhirakova/data-simulator
    environment:
      - SIM_HOST=${IP_B}
      - SIM_NAME=PRESS1
      - SIM_PERIOD=7
      - SIM_TYPE=pressure


EOF

docker compose up

