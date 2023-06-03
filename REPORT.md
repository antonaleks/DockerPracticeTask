## Настройки Docker и создание скриптов
Для настройки файла контейнера докера воспользуемся следующим конфигом конфигом

![image](assets/images/img.png)

Cоздадим образ на основе файла Dockerfile и контекста:

![image](assets/images/img_1.png)

Конфиг docker-compose файла симулятора выглядит следующим образом:

![image](assets/images/img_4.png)

Конфиг docker-compose файла сервера выглядит следующим образом:

![image](assets/images/img_5.png)

Запустим симулятор через докер:

![image](assets/images/img_6.png)

Загрузим на докер-хаб:

![image](assets/images/img_7.png)

В результате на докер-хабе у нас появится json образ симулятора:

![image](assets/images/img_8.png)

А в самом докере у нас появится новый контейнер temperature:

![image](assets/images/img_9.png)

Запустим контейнер с mosquitto брокером (в результате запуска контейнера с симулятором датчика увидим подключение):

![image](assets/images/img_2.png)

А так же в самом докере появится контейнер с mosquitto брокером:

![image](assets/images/img_12.png)

После запуска симулятора можно будет отследить работу брокера:

![image](assets/images/img_10.png)

## Работа с PlayWithDocker

С помощью команды загрузим все нужные файлы:

```shell
$ git clone -b develop https://github.com/Chilipinas/DockerPractice.git
```
### Клиент (Докер 1)
После запуска simulator.sh скрипта на виртуальной машине развернется три контейнера с разными симуляторами датчиков. Так же автоматически настроится ip route к серверу gateway.

![image](assets/images/img_11.png)

### Шлюз (Докер 2)
После запуска gateway.sh будет настроен путь к двум другим серверам, так же будет запущен контейнер с брокером

![image](assets/images/img_13.png)

### Сервер (Докер 3)
После запуска server.sh будет настроен ip route а так же запущены три контейнера

![image](assets/images/img_14.png)

![image](assets/images/img_15.png)

![image](assets/images/img_16.png)

Настройка базы данных grafana:

![image](assets/images/img_17.png)

Проверим результаты работы, для этого создадим и настроим Dashboard:wa