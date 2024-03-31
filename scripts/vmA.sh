#!/bin/bash
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

echo "Loading resources"
git clone https://github.com/AlexanderSynex/DockerPractice.git

mkdir docker

cp.
cd docker
docker pull alexandersynex/data-simulator

# echo "Installing dependecies for web server (Python Flash)"
# pip install flask

# echo "Web server configuration added %s" "app.py"
# touch app.py

# cat <<EOF >app.py
# from flask import Flask, request
# app = Flask(__name__)

# users = {}

# @app.route('/')
# def home():
#    return "Hello world\n"


# @app.route('/users', methods=['POST'])
# def post():
#    user = request.args.get('user')
   
#    if user is None:
#       return "Can not add user\n"

#    if user not in users:
#       users[user] = 0
#       return "POST. User added\n"

#    return f"POST. User already added\n"


# @app.route('/users', methods=['PUT', 'GET'])
# def getput():
#    user = request.args.get('user')
   
#    if request.method == 'GET' and user is None:
#       res = "\nAll users:\n"
#       for usr in users:
#          res += f"\t{usr}\n"
#       return res
   
#    if user is None:
#       return "User undefined\n"
   
#    if user not in users:
#       return "Can not find user\n"
   
#    users[user] += 1

#    return f"{user} -> {users[user]}\n"


# app.run(host='0.0.0.0', port=5000)
# EOF

# echo "Starting web server!"
# python app.py
