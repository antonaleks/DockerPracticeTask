#!/bin/bash

echo "SSH address: "
read ADDR

echo "Sending start shell-script to $ADDR"
scp vmA.sh $ADDR:~

echo "Connecting to $ADDR"
ssh $ADDR
