## Подготовка скрипта с данными

Создаем модуль "sensor.py", который будет генерировать наши данные подобно реальным датчикам на производстве. Тут есть наследуемый класс "Sensor" с абстрактными методами.
Есть 3 наследника у класса Sensor:
- датчик температуры Temperature
- датчик давления Pressure
- датчик тока Current

Создадим и настроим конфиг файл докер-образа

![](./assets/Screenshot_18.png) 

Проверим, компилируется ли докер-образ.

```shell
$ docker build -t ilyakonstantinovich/sensor-sim .
```
![](./assets/Screenshot_1.png) 
Также в  терминале проверим работу брокера москитто. С помощью Docker Desktop и MQQT Explorer посмотрим, запустился ли брокер и получает ли он что-то.
```shell
$ docker run -it --rm -p 10000:1883 \
    -v $PWD\mosquitto\config\mosquitto.conf:/mosquitto/config/mosquitto.conf  eclipse-mosquitto
```
```shell
$ docker run -e SIM_HOST=192.168.219.193 \
-e SIM_TYPE=temperature --name temperature \
ilyakonstantinovich/sensor-sim
```
![](./assets/Screenshot_2.png) 

![](./assets/Screenshot_3.png) 

![](./assets/Screenshot_4.png)

![](./assets/Screenshots/Screenshot_3.png)

Теперь нужно залить наш докер контейнер в Docker Hub

```shell
$ docker image push ilyakonstantinovich/sensor-sim:latest
```
![](./assets/Screenshot_5.png)


![](./assets/Screenshot_6.png)

Теперь сконфигурируем и используем docker-compose, чтобы работать сразу с несколькими контейнерами и получать данные с разных "датчиков". Конфигурируем файл "docker-compose.yml" 
![](./assets/Screenshot_10.png)
Запуск контейнеров:
```shell
$ docker-compose up -d --no-deps --build
```
![](./assets/Screenshot_7.png)
![](./assets/Screenshot_8.png)
![](./assets/Screenshot_9.png)

Теперь для работы с виртуальными машинами, нужно скопировать туда наши файлы.

```shell
scp -P 40000 -r .\vms\server\infra golovakov_1@localhost:/home/golovakov_1/infra
scp -P 40001 -r .\vms\gateway\mosquitto golovakov_2@localhost:/home/golovakov_2/mosquitto
scp -P 40002 -r .\vms\client\simulator golovakov_3@localhost:/home/golovakov_3/sensor_sim

```
Зайдем на виртуальные машины и увидим, что файлы перекинулись.

![](./assets/Screenshot_11.png)

## Работа на виртуальной машине - Gateway
Необходимо запустить докер файлы на каждой виртуальной машине.

```shell
$ sudo docker run -p 1883:1883 \
    -v $PWD/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf  \
    --name broker eclipse-mosquitto
```

## Работа на виртуальной машине - Client

```shell
$ docker-compose up -d --no-deps --build
```

## Работа на виртуальной машине - Server

```shell
$ sudo docker-compose up
```
![](./assets/Screenshot_20.png)

Подключаемся к Grafana  и делаем проброску портов у первой виртуальной машины 

![](./assets/Screenshot_21.png)

Проверим подключение к grafana через браузер ```localhost:45000```

![](./assets/Screenshot_13.png)

![](./assets/Screenshot_14.png)

Здесь построим графики из полученных через брокера данных от датчиков

![](./assets/Screenshot_15.png)

Также сделаем правила для порта 1883 в iptables

```shell
$ sudo iptables -L
$ sudo iptables -A OUTPUT -o enp0s8 -p tcp --syn --dport 1883 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -A OUTPUT -o enp0s9 -p tcp --syn --dport 1883 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -A INPUT -i enp0s8 -p tcp --syn --dport 1883 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -A INPUT -i enp0s9 -p tcp --syn --dport 1883 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
```

![](./assets/Screenshot_17.png)

После внесения изменений необходимо их сохранить

```shell
$ sudo su
root# sudo iptables-save > /etc/iptables/rules.v4
root# sudo ip6tables-save > /etc/iptables/rules.v6
root# exit
```

```shell
$ sudo tcpdump -i enp0s9 not icmp
```

![](./assets/Screenshot_16.png)