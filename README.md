# Введение
Данная практика посвещена базовым принципам Docker. Для выполнения практики необходимо развернуть контейнеры на локальном хосте.

# Задание

Необходимо развернуть следующую систему:

![image](assets/images/DockerTask.png)

Симуляторы сенсоров, развернутые в докер контейнерах, публикуют сообщения на Mqtt брокер. Сервис Consumer подписывается на все сообщение, опубликованные в брокере, и заносит их в базу данных временных рядов. Сервис dashboard отображает графики полученных данных от сервисов.

# Решение
# Настройка в client'e

В начале работы нам необходимо создать еще один класс датчиков в файле `sensor.py`, было решено добавить датчик влажности (humidity). Датчик гененрирует процет влажности в пределах от 30% до 70%.


<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/ebe95e94-b891-49d5-afd8-58c921add801">
</p>


Мы добавили датчик, теперь внесем измнения и  в файл 'main.py'

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/1a637313-11e8-4849-89a7-83fcbe4f9d6f">
</p>

С датчиками готово. Настроим Dockerfile:

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/9c8d09fc-98fe-470a-8bab-b78968176684">
</p>

Докерфайл готов. Можем перейти к следующему шагу - настройка requirements. 

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/2649cca7-6fea-4900-90bd-2a8be88b8c81">
</p>

Теперь сбилдим образ

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/e0ba0144-83b7-4617-9158-555b45051f1a">
</p>

# Настройка gateway (mqtt-брокер)

Для начала создадим файл mosquitto.conf.

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/92982076-8cb7-4063-83b2-1cd8ecedccec">
</p>

Далее создаём файл docker-compose.yml

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/3bfadad6-f96c-4fc2-8916-744e4298d66e">
</p>

Запускаем и видим, что, брокер работает

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/3aa3d40a-77d3-473f-ba96-02df4ac2b454">
</p>

Подправим наш 'docker-compose.yml' в client'e

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/97d55dc1-0d8e-4bf2-85a7-c552b0980223">
</p>

Обновим docker-compose командой 'docker-compose up'
Присоедимся к брокеру и увидим ответ от брокера

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/3b7399c2-8477-4886-b09f-eb9b3342b23c">
</p>

# Настройка server'a 

В первую очередь настроим telegraf, так как он получает данные с mqqt-брокера, а затем сохраняются в InfluxDB и визуализируются в Grafana. В 'telegraf.conf' необходимо настроить следующее:

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/4dccf819-ef25-4e3a-a9aa-df0e8427ad3e">
</p>

Теперь  telegraf читает данные с 1883 порта по IP 192.168.0.112

Посмотрим работу наших образов 

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/aca322b5-a72b-463b-8469-2aeb6fb1e975">
</p>

Поднимем Grafana на 3000 порту 

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/c4ffde76-da9f-417c-bc0e-cd4a80816c08">
</p>

Залогинимся 

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/dacd6be0-1693-4903-aad7-298e4187df4a">
</p>

Посмотрим на отображение данных, имеется ли оно

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/460709b3-ae81-484f-a5b1-d1ccf4b5a435">
</p>

Все работает, можем приступить к настройке графиков 

# Настройка графиков

Посмотрим, что мы видим InfluxDB в Grafana

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/fb0002e4-f504-4c48-b5e0-d1d3974fed0f">
</p>

Все ок, переходим к выводу графиков. Нам нужно вывести все наши сенсоры (Pressure, Temperature, Humidity, Current)

<p align="center">
  <img src="https://github.com/hanz0m4/DockerPractice/assets/166024789/765833de-aab5-4567-9762-a637efa2e6fe">
</p>

Все готово, на этом наше задание выполнено.

