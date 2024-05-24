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
* `sudo usermod -a -G docker gavrilenko_1` для server
* `sudo usermod -a -G docker gavrilenko_2` для gateway
* `sudo usermod -a -G docker gavrilenko_3` для client

Теперь создадим образ при помощи команды:
`docker build -t vespuchka/simulator . `

<p align="center">
<img width=100% src = "assets\images\img_DockerBuild.png">
Рисунок 1 - Создание образа
</p>

Получили docker образ, из которого можно развернуть контейнер:

<p align="center">
<img width=100% src = "assets\images\img_CreatedImg.png">
Рисунок 2 - Созданный образ
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
      - SIM_HOST=192.168.0.104
      - SIM_NAME=TEMP1
      - SIM_PERIOD=2
      - SIM_TYPE=temperature

  pressure_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=PRESS1
      - SIM_PERIOD=2
      - SIM_TYPE=pressure

  current_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=CUR1
      - SIM_PERIOD=6
      - SIM_TYPE=current

  humidity_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=HUM1
      - SIM_PERIOD=4
      - SIM_TYPE=humidity

  temp_slow_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=TEMP2
      - SIM_PERIOD=15
      - SIM_TYPE=temperature

  humidity_slow_sensor:
    image: vespuchka/simulator:latest
    environment:
      - SIM_HOST=192.168.0.104
      - SIM_NAME=HUM2
      - SIM_PERIOD=15
      - SIM_TYPE=humidity
```

## Настройка брокера - Mosquitto

Для настройки брокера необходимо создать конфигурационный файл *mosquitto.conf* со следующим содержимымы:
```c
listener 1883
allow_anonymous true
```

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
Напоследок сконфигурируем порты:
```
sudo iptables -A OUTPUT -o enp0s8 -p tcp --syn --dport 1883 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -o enp0s9 -p tcp --syn --dport 1883 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i enp0s8 -p tcp --syn --dport 1883 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i enp0s9 -p tcp --syn --dport 1883 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
```

Теперь запустим контейнер с брокером:

<p align="center">
<img width=100% src = "assets\images\img_MosqCont.png">
Рисунок 3 - Запущенный контейнер с брокером
</p>

Далее запустим на ВМ клиента одновременно 6 контейнеров, симулирующих работу датчиков:

<p align="center">
<img width=100% src = "assets\images\img_6Cont.png">
Рисунок 4 - Запуск 6 контейнеров
</p>

При этом брокер отобразит подключение:

<p align="center">
<img width=100% src = "assets\images\img_6logRecieved.png">
Рисунок 5 - Логи брокера при подключении датчиков
</p>

Проверим также данные от датчиков в MQTT explorer:

<p align="center">
<img width=100% src = "assets\images\img_MQTT.png">
Рисунок 6 - Данные в MQTT explorer
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
servers = ["tcp://192.168.0.104:1883"] # адрес vm с mqtt-брокером
```
### IfluxDB

Для *Influxdb* используем образ `influxdb:1.8`. Загрузим его при помощи команды `docker pull influxdb:1.8`

Теперь настроим конфигурационный файл `influxdb-init.iql` для корректной работы influxdb. Укажем в нём какую таблицу создавать - *sensors*:

*influxdb-init.iql*
```SQL
CREATE database sensors
CREATE USER telegraf WITH PASSWORD 'telegraf' WITH ALL PRIVILEGES
```
### Grafana

Данные для отображения датчиков берутся из InfluxDB. Для настройки в конфигурационном файле `default.yaml` в папке `datasourse` необходимо прописать следующее:

*default.yaml*
```yaml
apiVersion: 1

datasources:
  - name: InfluxDB_v1
    type: influxdb
    access: proxy
    database: sensors
    user: telegraf
    url: http://influxdb:8086
    jsonData:
      httpMode: GET
    secureJsonData:
      password: telegraf
```
Теперь запустим все три контейнера при помощи docker-compose, но для начала сконфигурируем `docker-compose.yml`:

*docker-compose.yml*
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

Теперь можно выполнять команду `docker-compose up`:

<p align="center">
<img width=100% src = "assets\images\img_ServCont.png">
Рисунок 7 - Запуск контейнеров
</p>

Логи брокера на машине B:

<p align="center">
<img width=100% src = "assets\images\img_servLogs.png">
Рисунок 8 - Подключение telegraf в логах на машине B
</p>

### Настройка dashboard в Grafana

После запуска всех необходимых контейнеров, в браузере переходим по `192.168.0.102:3000`

<p align="center">
<img width=100% src = "assets\images\img_Start.png">
</p>

Для проверки соединения перейдем в Menu -> Connections -> Data sources. Находим в истончиках InfluxDB и проверяем подключение:
<p align="center">
<img width=100% src = "assets\images\img_Sost.png">
</p>

После переходим через Меню в раздел Dashboards, где создаем собственный дашбоард. 

<p align="center">
<img width=100% src = "assets\images\img_New.png">
</p>

Для отображения данных необходимо настроить запросы (query)

<p align="center">
<img width=100% src = "assets\images\img_Dash.png">
</p>

После создания необходимо количества графиков, отображающих данные с Simluator, экспортируем дашборд как JSON-файл

Для этого находим функцию `Share` -> ``Export` -> `Save to file`. Сохраненный файл помещаем в папку `vms\server\infra\grafana\provisioning\dashboards\mqtt.json`

Настроенный в нашем случае дашборд выглядит вот так:

<p align="center">
<img width=100% src = "assets\images\img_DONE.png">
</p>
