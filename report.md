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
Приложение будет развёрнуто в docker контейнер с подключением python-alpine 3.19.
Сконфигурирем файл `Dockerfile` следующим образом:

``` Dockerfile
FROM python:alpine3.19
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "main.py"]
```
Создадим файл *requirements.txt*:
`paho_mqtt==1.6.1`

Также, добавил текущего пользователя ВМ в группу *docker*:
`sudo usermod -a -G docker gavrilenko_1`

Теперь создадим образ при помощи команды:
`docker build -t vespuchka/simulator . `

<p align="center">
<img width=100% src = "assets\images\.png">
</p>

Получили docker образ, из которого можно развернуть контейнер:

<p align="center">
<img width=100% src = "assets\images\.png">
</p>

Для запуска нескольких датчиков развернём docker-compose. Сконфигурируем файл *docker-compose.yml*, в котором укажем:
* Тип датчика
* Имя датчика
* Период отправки
* Адрес отправки

*docker-compose*
```yml
version: "3"

services:
  temp_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.100
      - SIM_NAME=TEMP1
      - SIM_PERIOD=2
      - SIM_TYPE=temperature

  pressure_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.100
      - SIM_NAME=PRESS1
      - SIM_PERIOD=2
      - SIM_TYPE=pressure

  current_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.100
      - SIM_NAME=CUR1
      - SIM_PERIOD=6
      - SIM_TYPE=current

  humidity_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.100
      - SIM_NAME=HUM1
      - SIM_PERIOD=4
      - SIM_TYPE=humidity

  temp_slow_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.100
      - SIM_NAME=TEMP2
      - SIM_PERIOD=15
      - SIM_TYPE=temperature

  humidity_slow_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.100
      - SIM_NAME=HUM2
      - SIM_PERIOD=15
      - SIM_TYPE=humidity
```

## Настройка брокера - Mosquitto

Получим образ *eclipse-mosquitto* MQTT-брокера, при помощи команды `docker pull eclipse-mosquitto`

Для настройки брокера необходимо создать конфигурационный файл *mosquitto.conf* со следующим содержимымы:
```c
listener 1883
allow_anonymous true
```
Для его подключения к образу используем docker volumes через флаг -v при запуске контейнера.

Также сформируем docker-compose файл.
*docker-compose*
```yml
version: "3"
services:
  broker:
    image: eclipse-mosquitto
    container_name: broker
    volumes:
      - ./mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf
    ports:
      - "1883:1883"
```
Создадим контейнер брокера, результат:

<p align="center">
<img width=100% src = "assets\images\.png">
</p>

Далее запустим на ВМ клиента одновременно 6 контейнеров, симулирующих работу датчиков:

<p align="center">
<img width=100% src = "assets\images\.png">
</p>

При этом брокер отобразит:

<p align="center">
<img width=100% src = "assets\images\.png">
</p>

## Отображение данных

Отображение будет происходить следующим образом:
* Настроим `Telegraf`, который будет подписываться на MQTT с данными от датчиков
* Эти данные будут сохраняться в `InfluxDB`
* Непосредственное отображение данных с датчиков будет реализовано при помощи `Grafana`

### Telegraf

Настроим `Telegraf` - изменим в конфигурационный файле *telegraf.conf* параметр `servers`:

*telegraf.conf*
```c
servers = ["tcp://192.168.0.101:1883"] # адрес vm с mqtt-брокером
```

