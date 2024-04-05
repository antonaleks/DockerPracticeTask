#!/bin/bash

## change the hostname
hostname sensorhost
## restart docker
sudo service docker restart

echo "Configuring adapter for subnet A"
echo "Creating MacVlan adapter"
ip link add macvlan1 link eth0 type macvlan mode bridge
echo "Adapter successfully created"

printf "\nLinking MacVlan adapter to ip address %s\n" "192.168.28.10/24"
ip address add dev macvlan1 192.168.28.10/24
echo "Enabling adapter"
ip link set macvlan1 up
echo "Adapter enabled"

echo "Routing through %s to %s" "192.168.4.0/24" "192.168.28.1"
ip route add 192.168.4.0/24 via 192.168.28.1

echo "Creating sensors config file"
touch docker-compose.yml

echo "Setting broker ip as env variable"
export MQTT_IP=192.168.28.1

echo "Creating containers config"
cat <<EOF >docker-compose.yml
version: "3"

services:
  temp_sensor:
    image: alexandersynex/simulator
    environment:
      - SIM_HOST=${MQTT_IP}
      - SIM_NAME=TEMPSENS2
      - SIM_PERIOD=2
      - SIM_TYPE=temperature

  temp_low_freq_sensor:
    image: alexandersynex/simulator
    environment:
      - SIM_HOST=${MQTT_IP}
      - SIM_NAME=TEMPLOWFREQSENS2
      - SIM_PERIOD=10
      - SIM_TYPE=temperature

  pressure_sensor:
    image: alexandersynex/simulator
    environment:
      - SIM_HOST=${MQTT_IP}
      - SIM_NAME=PRSENS5
      - SIM_PERIOD=5
      - SIM_TYPE=pressure

  current_sensor:
    image: alexandersynex/simulator
    environment:
      - SIM_HOST=${MQTT_IP}
      - SIM_NAME=CURSENS2
      - SIM_PERIOD=2
      - SIM_TYPE=current

  accel_slow_sensor:
    image: alexandersynex/simulator
    environment:
    - SIM_HOST=${MQTT_IP}
      - SIM_NAME=ACCELSLOWSENS5
      - SIM_PERIOD=5
      - SIM_TYPE=current

  accel_fast_sensor:
    image: alexandersynex/simulator
    environment:
    - SIM_HOST=${MQTT_IP}
      - SIM_NAME=ACCELFASTSENS2
      - SIM_PERIOD=2
      - SIM_TYPE=current 
EOF

echo "Starting sensors environment"
docker compose up
