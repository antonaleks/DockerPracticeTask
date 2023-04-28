- Install on each virtual machine docker and docker-compose.


![1- version A](https://user-images.githubusercontent.com/25878224/234697074-ee27f537-754b-4935-a552-43f76bdc7843.PNG)

![1- version B](https://user-images.githubusercontent.com/25878224/234697168-816b99c6-c84f-45f1-a5b7-a51d7c514424.PNG)

![1- version c](https://user-images.githubusercontent.com/25878224/234697182-737a155a-0f8f-4ab9-84e7-6c8fa20391fb.PNG)

# Linux A
1- Create the four Sensors classes (Temperature, Pressure, Current, Humidity) by module "sensor.py"

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

# Linux B

# Linux C
