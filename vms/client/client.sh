#! /bin/bash
# script to create the third virtual machine
ip link add macvlan1 link eth0 type macvlan mode bridge
ip address add dev macvlan1 192.168.4.100/24
ip link set macvlan1 up
ip route add 192.168.18.0/24 via 192.168.4.1 
while [ true ] ; do
read -t 3 -n 1
if [ $? = 0 ] ; then
break ;
else
echo "waiting for the keypress"
fi
done
