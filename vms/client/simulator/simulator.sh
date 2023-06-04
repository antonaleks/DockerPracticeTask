#!/bin/bash
IpA=192.168.19.10/24
IpB=192.168.19.1
IpC=192.168.8.0/24

echo -e "создаем новый адаптер с типом bridge и делаем связь адаптера с eth0: \n ip link add macvlan1 link eth0 type macvlan mode bridge"
ip link add macvlan1 link eth0 type macvlan mode bridge

echo -e "добавляем ip адрес адаптеру: \n ip address add dev macvlan1 192.168.19.10/24"
ip address add dev macvlan1 $IpA

echo -e "включаем адаптер: \n ip link set macvlan1 up"
ip link set macvlan1 up

echo -e "добавляем маршрут к виртуалке С через виртуалку В: \n ip route add 192.168.8.0/24 via 192.168.19.1"
ip route add $IpC via $IpB

docker-compose up -d