from entity.sensor import Temperature,Pressure,Current,Humidity
import time

input_type="temperature"

sensors={"temperature":Temperature,"pressure":Pressure,"current":Current,"humidity":Humidity}

sensor=sensors[input_type](name="sensor_1")

while True:
    sensor.generate_new_value()
    print(sensor)
    time.sleep(1)