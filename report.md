# *Отчет*: Взаимодействие docker-контейнеров

**Выполнил** Маликов Александр

**Группа** 5142704/30801 

## Датчики

Для формирования данных было написано приложение на Python, имитирующее поведение датчиков. Оно генерирует данные с определенным периодом и отправляет их. Для отправки данных используется протокол MQTT.
Реализовано 4 типа датчиков (Температура, Давление, Ток, Ускорение), наследующихся от базового класса Sensor.
Код на Python:

*sensor.py*
```py
import random


class Sensor:
    value: float
    name: str
    type: str

    def __init__(self, name):
        self.name = name

    def generate_new_value(self):
        pass

    def get_data(self):
        return self.value

    def __str__(self):
        return {"type": self.type, "name": self.name, "value": self.value}


class Temperature(Sensor):
    step = 25

    def __init__(self, name):
        super().__init__(name)
        self.type = "temp"

    def generate_new_value(self):
        self.value = random.random() + self.step


class Pressure(Sensor):
    step = 55

    def __init__(self, name):
        super().__init__(name)
        self.type = "pressure"

    def generate_new_value(self):
        self.value = random.random() + self.step - 56.48 + 25 * 7


class Current(Sensor):
    def __init__(self, name):
        super().__init__(name)
        self.step = 0
        self.type = "current"
        
        self.generate_new_value()

    def generate_new_value(self):
        import math
        self.value = math.sin(self.step)
        self.step = self.step + 1


class Acceleration(Sensor):
    step = 0
    
    def __init__(self, name):
        super().__init__(name)
        self.type = "acceleration"

    def generate_new_value(self):
        self.value = self.step ** 2
        if (self.value > 5e5):
            self.value = 5e5
        self.step += 1
```

*main.py*
```py
import paho.mqtt.client as mqttclient
from os import environ
import time

from entity.sensor import *

broker = "localhost" if "SIM_HOST" not in environ.keys() else environ["SIM_HOST"]
port = 1883 if "SIM_PORT" not in environ.keys() else int(environ["SIM_PORT"])
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


def on_publish(client,userdata,result):             #create function for callback
    print("data published")

print(f"Configuring {type_sim} {name} {broker}:{port} T={period}")

sensor = sensors[type_sim](name=name)
client1 = mqttclient.Client(sensor.name)  # create client object
client1.on_connect = on_connect
client1.on_publish = on_publish  # assign function to callback


print("Client configured!")


client1.connect(broker, port=port)  # establish connection
client1.loop_start()
while True:
    sensor.generate_new_value()
    ret= client1.publish(f"sensor/{sensor.name}", sensor.get_data())
    time.sleep(period)
    
client1.loop_stop()
client1.disconnect()
```
Приложение было развернуто в docker контейнер с подключением python-alpine версии 3.19. Библиотеки, подключаемые к python: paho_mqtt версии 1.6.1 (реализует протокол MQTT). 

*Dockerfile*:
```dockerfile
FROM python:alpine3.19
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "main.py"]
```
Для запуска нескольких контейнеров развернут docker-compose файл, регламентирующий 6 контейнеров для 4-х типов датчиков, в котором указывается:
- Тип датчика
- Имя датчика
- Период отправки
- Адрес отправки

*docker-compose*
```yml
version: "3"

services:
  temp_sensor:
    image: alexandersynex/data-simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=TEMPSENS2
      - SIM_PERIOD=2
      - SIM_TYPE=temperature

  temp_low_freq_sensor:
    image: alexandersynex/data-simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=TEMPLOWFREQSENS2
      - SIM_PERIOD=10
      - SIM_TYPE=temperature

  pressure_sensor:
    image: alexandersynex/data-simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=PRSENS5
      - SIM_PERIOD=5
      - SIM_TYPE=pressure

  current_sensor:
    image: alexandersynex/data-simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=CURSENS2
      - SIM_PERIOD=2
      - SIM_TYPE=current

  accel_slow_sensor:
    image: alexandersynex/data-simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=ACCELSLOWSENS5
      - SIM_PERIOD=5
      - SIM_TYPE=current

  accel_fast_sensor:
    image: alexandersynex/data-simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=ACCELFASTSENS2
      - SIM_PERIOD=2
      - SIM_TYPE=current
```

Результат запуска контейнеров приведен ниже

<img src="assets/images/sensors compose up.png">

## Брокер
Для приема данных по MQTT используется MQTT-брокер, реализованный в образе `eclipse-mosquitto`.

Получаем образ командой `docker pull eclipse-mosquitto`
Для настройки брокера создаем конфигурационный файл `mosquitto.conf`. Для его подключения к образу используем `docker volumes` через флаг `-v` при запуске контейнера.

*mosquitto.conf*
```yml
listener 1883
allow_anonymous true
```

Для удобного запуска контейнера сформирован docker-compose файл.

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

Результат запуска контейнера-брокера приведен ниже

<img src="assets/images/mqtt compose up.png">

## Отображение данных
Отображение данных осуществлялось посредствам 3-х контейнеров: `telegraf`, `influxdb`, `grafana`.

### InfluxDB
InfluxDB предоставляет возможность хранения данных получаемых в реальном времени. Идеально для данной задачи.

Образ, используемый в задаче: `influxdb:1.8`.

Для работы influxdb необходимо создать конфигурационный файл, в котором указать какую таблицу создать, для данной задачи - таблица sensors. Также создается пользователь *telegraf* для подключения контейнера `telegraf` к базе.

*influxdb-init.iql*
```SQL
CREATE database sensors
CREATE USER telegraf WITH PASSWORD 'telegraf' WITH ALL PRIVILEGES
```

 Все команды передаются через скрипт благодаря отображению в контейнер через volume. Все настройки указываются в compose-файле.

### Telegraf
Telegraf предназначен для считывания данных из брокера и записи их в базу данных, в данном случае `influxdb`.

Для контейнера создается конфигурационный файл `telegraf.conf`, в котором указывается откуда брать данные (адрес брокера) и куда их записывать (адрес БД).

*telegraf.conf*
```yml
[global_tags]
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = "0s"
    hostname = ""
    omit_hostname = false
[[outputs.influxdb]]
urls = ["http://influxdb:8086"] 
database = "sensors"
skip_database_creation = true
username = "telegraf"
password = "telegraf"
[[inputs.cpu]]
    percpu = true
    totalcpu = true
    collect_cpu_time = false
    report_active = false
[[inputs.disk]]
    ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
[[inputs.diskio]]
[[inputs.kernel]]
[[inputs.mem]]
[[inputs.processes]]
[[inputs.swap]]
[[inputs.system]]
[[inputs.mqtt_consumer]]
servers = ["tcp://192.168.0.104:1883"] 
topics = ["sensors/#"]
data_format = "value"
data_type = "float"
```

### Grafana
Grafana позволяет выводить данные в реальном времени в виде графиков. Grafana позволяет создавать панели, содержащие множество графиков и постоянно их обновлять. Кроме того, она предоставляет приятный интерфейс из веб-браузера и аутентификацию.

<img src="assets/images/grafana login page.png">

В интерфейсе Grafana проверяется, что подключен источник данных - InfluxDB.

<img src="assets/images/grafana data sources.png">

Для проверки можно нажать на источник данных и проверить наличие данных.

<img src="assets/images/grafana data source test.png">


Далее необходимо создать dashboard с панелями для графиков данных.

<img src="assets/images/grafana dashboard create.png">

На созданном дашборде можно создать панель, которая будет отображать данные.

<img src="assets/images/grafana creaing new panel.png">

Созданный дашборд можно сохранить в json файле и загружать при запуске Grafana посредствам volume.

### Развертывание среды визуализации

Для запуска контейнеров с заданными настройками создан docker-compose файл.

```yml
version: "3"
services:
  influxdb:
    image: influxdb:1.8
    container_name: influxdb
    volumes:
      - ./influxdb/scripts:/docker-entrypoint-initdb.d
      - influx_data:/var/lib/influxdb
    networks:
      - server-net
  telegraf:
    image: telegraf
    container_name: telegraf
    volumes:
      - ./telegraf:/etc/telegraf:ro
    restart: unless-stopped
    networks:
      - server-net
  grafana:
    image: grafana/grafana
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/:/etc/grafana/
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    restart: unless-stopped
    ports:
      - 3000:3000
    networks:
      - server-net


volumes:
  influx_data: {}
  grafana_data: {}

networks:
  server-net: {}
```

Результат запуска контейнеров приведен ниже

<img src="assets/images/server compose up.png">

## Пример работы 

При запуске всех контейнеров можно зайти в веб-интерфейс Grafana и проверить работу посредствам дашборда.

*Результат работы*

<img src="assets/images/grafana example.png">

Графики обновляются периодически и показывают совместную работу всех контейнеров.

## Конец

```
             *     ,MMM8&&&.            *
                  MMMM88&&&&&    .
                 MMMM88&&&&&&&
     *           MMMЭТО_ФСЁ&&&
                 MMM88&&&&&&&&
                 'MMM88&&&&&&'
                   'MMM8&&&'      *
          |\___/|
          )     (             .              '
         =\     /=
           )===(       *
          /     \
          |     |
         /       \
         \       /
  _/\_/\_/\__  _/_/\_/\_/\_/\_/\_/\_/\_/\_/\_
  |  |  |  |( (  |  |  |  |  |  |  |  |  |  |
  |  |  |  | ) ) |  |  |  |  |  |  |  |  |  |
  |  |  |  |(_(  |  |  |  |  |  |  |  |  |  |
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  jgs|  |  |  |  |  |  |  |  |  |  |  |  |  |
```