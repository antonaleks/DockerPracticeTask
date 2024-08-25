#! /bin/bash
# script to create the First virtual machine

echo -e "-Create a server dirctory and create app.py inside it\n and install flask and tcpdump\nand run bash again\n" 
while [ true ] ; do
read -t 3 -n 1
if [ $? = 0 ] ; then
break;
else
echo "waiting for the keypress" 
fi
done
ip link add macvlan1 link eth0 type macvlan mode bridge
ip address add dev macvlan1 192.168.18.10/24
ip link set macvlan1 up 
ip route add 192.168.4.0/24 via 192.168.18.1 
