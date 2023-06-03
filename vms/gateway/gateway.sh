#!/bin/bash
IpB1=192.168.19.1/24
IpB2=192.168.8.1/24


echo -e "создаем новый адаптер с типом bridge и делаем связь адаптера с eth0: \n ip link add macvlan1 link eth0 type macvlan mode bridge"
ip link add macvlan1 link eth0 type macvlan mode bridge
echo -e "добавляем ip адрес адаптеру: \n ip address add dev macvlan1 192.168.19.1/24"
ip address add dev macvlan1 $IpB1
echo -e "включаем адаптер: \n ip link set macvlan1 up"
ip link set macvlan1 up

echo -e "создаем новый адаптер с типом bridge и делаем связь адаптера с eth0: \n ip link add macvlan2 link eth0 type macvlan mode bridge"
ip link add macvlan2 link eth0 type macvlan mode bridge
echo -e "добавляем ip адрес адаптеру: \n ip address add dev macvlan2 192.168.8.1/24"
ip address add dev macvlan2 $IpB2
echo -e "включаем адаптер: \n ip link set macvlan2 up"
ip link set macvlan2 up

docker run -v $PWD/mosquitto:/mosquitto/config -p 1883:1883 --name broker --rm eclipse-mosquitto