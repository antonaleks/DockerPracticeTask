#!/bin/bash

echo "SSH address: "
read ADDR

echo "Sending docker-compose file to $ADDR"
scp ../vms/client/simulator/docker-compose.yml $ADDR:~

echo "Sending start shell-script to $ADDR"
scp vmA.sh $ADDR:~

echo "Connecting to $ADDR"
ssh $ADDR
