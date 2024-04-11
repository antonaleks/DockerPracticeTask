#!/bin/bash

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

echo "Loading InfluxDB, Telegraf, Grafana containers"
echo "InfluxDB container"
docker pull influxdb:1.8
echo "Telegraf container"
docker pull telegraf
echo "Grafana container"
docker pull grafana/grafana

echo "Creating telegraf config"
mkdir telegraf
touch telegraf/telegraf.conf
cat << EOF > telegraf/telegraf.conf
[global_tags]
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = "0s"
  hostname = ""
  omit_hostname = false
[[outputs.influxdb]]
  urls = ["http://influxdb:8086"] 
  database = "sensors"
  skip_database_creation = true
  username = "telegraf"
  password = "telegraf"
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
[[inputs.diskio]]
[[inputs.kernel]]
[[inputs.mem]]
[[inputs.processes]]
[[inputs.swap]]
[[inputs.system]]
[[inputs.mqtt_consumer]]
  servers = ["tcp://192.168.4.1:1883"] 
  topics = ["sensors/#"]
  data_format = "value"
  data_type = "float"
EOF

echo "Creating containers config"
mkdir -p influxdb/scripts
touch influxdb/scripts/influxdb-init.iql
cat << EOF > influxdb/scripts/influxdb-init.iql
CREATE DATABASE sensors;
CREATE USER telegraf WITH PASSWORD 'telegraf' WITH ALL PRIVILEGES;
EOF

echo "Creating containers config"
touch docker-compose.yml

mkdir grafana
touch ./grafana/grafana.ini

cat << EOF > ./grafana/grafana.ini
[paths]
[server]
[database]
[datasources]
[remote_cache]
[dataproxy]
[analytics]
[security]
[snapshots]
[dashboards]
[users]
[auth]
[auth.anonymous]
[auth.github]
[auth.gitlab]
[auth.google]
[auth.grafana_com]
[auth.azuread]
[auth.okta]
[auth.generic_oauth]
[auth.basic]
[auth.proxy]
[auth.jwt]
[auth.ldap]
[aws]
[azure]
[smtp]
[emails]
[log]
[log.console]
[log.file]
[log.syslog]
[log.frontend]
[quota]
[unified_alerting]
[alerting]
[annotations]
[annotations.dashboard]
[annotations.api]
[explore]
[query_history]
[metrics]
[metrics.environment_info]
[metrics.graphite]
[grafana_com]
[tracing.jaeger]
[tracing.opentelemetry.jaeger]
[external_image_storage]
[external_image_storage.s3]
[external_image_storage.webdav]
[external_image_storage.gcs]
[external_image_storage.azure_blob]
[external_image_storage.local]
[rendering]
[panels]
[plugins]
[live]
[plugin.grafana-image-renderer]
[enterprise]
[feature_toggles]
[date_formats]
[expressions]
[geomap]
EOF

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
  influxdb:
    image: influxdb:1.8
    container_name: influxdb
    volumes:
      - ./influxdb/scripts:/docker-entrypoint-initdb.d
      - influx_data:/var/lib/influxdb
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
    networks:
      - server-net
  grafana:
    image: grafana/grafana
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/:/etc/grafana/

    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    restart: unless-stopped
    ports:
      - 3000:3000
    networks:
      - server-net
networks:
  server-net: {}
volumes:
  influx_data: {}
  grafana_data: {}
EOF


echo "Starting server environment"
docker compose up -d