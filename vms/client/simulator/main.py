import paho.mqtt.client as mqttclient
from os import environ
import time

from entity.sensor import *

broker = "localhost" if "SIM_HOST" not in environ.keys() else environ["SIM_HOST"]
port = 1883 if "SIM_PORT" not in environ.keys() else environ["SIM_PORT"]
name = "sensor" if "SIM_NAME" not in environ.keys() else environ["SIM_NAME"]
period = 1 if "SIM_PERIOD" not in environ.keys() else int(environ["SIM_PERIOD"])
type_sim = "temperature" if "SIM_TYPE" not in environ.keys() else environ["SIM_TYPE"]
sensors = {"temperature": Temperature, "pressure": Pressure, "current": Current, "acceleration": Acceleration}

isConnected = False

def on_connect(client,userdata,flags,rc):
    if rc == 0:
        print(f"Connected to {broker}")
        global isConnected
        isConnected = True
    else:
        print("Is not connected")


def on_publish(client, userdata, result):  # create function for callback
    print(f"data published {userdata}")
    pass

print(f"Configuring {type_sim} {name} {broker}:{port} T={period}")

sensor = sensors[type_sim](name=name)
client1 = mqttclient.Client(sensor.name)  # create client object
client1.on_connect = on_connect
client1.on_publish = on_publish  # assign function to callback
client1.connect(broker, port=port)  # establish connection

print("Client configured!")

client1.loop_start()

while not isConnected:
    print("Trying to connect")
    time.sleep(0.5)

# while True:
sensor.generate_new_value()
print(f"Generated values {sensor.get_data()}")
ret = client1.publish("sensors/" + sensor.type + "/" + sensor.name, sensor.get_data())  # publish
time.sleep(period)

client1.loop_stop()
