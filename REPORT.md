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

После запуска симулятора можно будет отследить работу брокера:

![image](assets/images/img_10.png)

## Работа с PlayWithDocker

С помощью команды загрузим все нужные файлы:

```shell
$ git clone -b develop https://github.com/Chilipinas/DockerPractice.git
```


