# *Отчет*: Взаимодействие docker-контейнеров

**Выполнил** Гавриленко Даниил

**Группа** 5142704/30801 

## Симуляция датчиков - генерация данных

Добавим четвёртый тип датчиков: в файле `sensor.py` создаем четвертый класс *Humidity*, который будет отвечать за датчики влажности.

```python
class Humidity(Sensor):
    step = 0

    def __init__(self, name):
        super().__init__(name)
        self.type = "humidity"

    def generate_new_value(self):
        import math
        self.value = math.sin(self.step) * 1.3 + random.random() * 0.2
        self.step = self.step + 1
```
Теперь реализуем клиента, который будет подключаться к mqtt брокеру и публиковать сообщения. Для этого создадим файл `main.py` со следующим кодом:

```python
import paho.mqtt.client as paho
from os import environ
import time

from entity.sensor import *

broker = "localhost" if "SIM_HOST" not in environ.keys() else environ["SIM_HOST"]
port = 1883 if "SIM_PORT" not in environ.keys() else int(environ["SIM_PORT"])
name = "sensor" if "SIM_NAME" not in environ.keys() else environ["SIM_NAME"]
period = 1 if "SIM_PERIOD" not in environ.keys() else int(environ["SIM_PERIOD"])
type_sim = "temperature" if "SIM_TYPE" not in environ.keys() else environ["SIM_TYPE"]
sensors = {"temperature": Temperature, "pressure": Pressure, "current": Current, "humidity": Humidity}


def on_publish(client, userdata, result):  # create function for callback
    print(f"data published {userdata}")
    pass


sensor = sensors[type_sim](name=name)
client1 = paho.Client(sensor.name)  # create client object
client1.on_publish = on_publish  # assign function to callback
client1.connect(broker, port)  # establish connection
while True:
    sensor.generate_new_value()
    ret = client1.publish("sensors/" + sensor.type + "/" + sensor.name, sensor.get_data())  # publish
    time.sleep(period)
```

