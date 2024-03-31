#!/bin/bash

echo "SSH address: "
read ADDR
echo "Script name: "
read FILE_NAME

echo "Sending $FILE_NAME to $ADDR"
scp $FILE_NAME $ADDR:~

echo "Connecting to $ADDR"
ssh $ADDR
