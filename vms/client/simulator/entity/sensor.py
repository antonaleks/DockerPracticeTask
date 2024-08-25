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
    step = 15

    def __init__(self, name):
        super().__init__(name)
        self.type = "temp"

    def generate_new_value(self):
        self.value = random.random() + self.step


class Pressure(Sensor):
    step = 65

    def __init__(self, name):
        super().__init__(name)
        self.type = "pressure"

    def generate_new_value(self):
        self.value = random.random() + self.step - 56.48 + 25 * 7


class Current(Sensor):
    step = 0

    def __init__(self, name):
        super().__init__(name)
        self.type = "current"

    def generate_new_value(self):
        import math
        self.value = math.sin(self.step)
        self.step = self.step + 1
        
class Humidity(Sensor):
    step = 0

    def __init__(self, name):
        super().__init__(name)
        self.type = "humidity"

    def generate_new_value(self):
        import math
        self.value = (math.cos(self.step + 3) + 2) * 10
        self.step = self.step + 4

