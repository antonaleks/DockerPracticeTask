#!/bin/bash
# Linux С

echo -e "Starting the first MACVLAN installation\n"

ip link add macvlan1 link eth0 type macvlan mode bridge
ip address add dev macvlan1 192.168.11.100/24
ip link set macvlan1 up
ip route add 192.168.14.0/24 via 192.168.11.1

echo -e "Ending the first MACVLAN installation\n\n"

docker pull influxdb

docker run -d -p 8086:8086 -v influx:/var/lib/influxdb --name influxdb influxdb:1.8

docker exec -it influxdb influx
CREATE database sensors
USE sensors
CREATE USER telegraf WITH PASSWORD 'telegraf' WITH ALL PRIVILEGES


# touch influxdb-init.iql

# cat << EOF > influxdb-init.iql
# CREATE database sensors
# USE sensors
# CREATE USER telegraf WITH PASSWORD 'telegraf' WITH ALL PRIVILEGES
# EOF

# mkdir -p ~/influxdb/scripts

# mv -v ~/influxdb-init.iql ~/influxdb/scripts

docker pull telegraf

docker run --rm telegraf telegraf config > telegraf.conf

cat <<\EOF>> telegraf.conf
# в блок mqtt_consumer
servers = ["tcp://192.168.1.1:1883"] # адрес vm с mqtt-брокером
topics = [
  "sensors/#"
]
data_format = "value"
data_type = "float"

# в блок [outputs.influxdb]    
urls = ["http://influxdb:8086"] # адрес докера с influxdb (указать alias при docker-compose)
database = "sensors"
skip_database_creation = true
username = "telegraf"
password = "telegraf"

EOF
