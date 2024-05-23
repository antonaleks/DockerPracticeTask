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
