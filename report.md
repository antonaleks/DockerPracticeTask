- Install on each virtual machine docker and docker-compose.


![1- version A](https://user-images.githubusercontent.com/25878224/234697074-ee27f537-754b-4935-a552-43f76bdc7843.PNG)

![1- version B](https://user-images.githubusercontent.com/25878224/234697168-816b99c6-c84f-45f1-a5b7-a51d7c514424.PNG)

![1- version c](https://user-images.githubusercontent.com/25878224/234697182-737a155a-0f8f-4ab9-84e7-6c8fa20391fb.PNG)

# Linux A
1- Create the four Sensors classes (Temperature, Pressure, Current, Humidity) by module "sensor.py"

![A- 1 sensor ](https://user-images.githubusercontent.com/25878224/235059677-3d219643-9710-4199-8916-76d7c819f968.PNG)

![A- 2 sensor ](https://user-images.githubusercontent.com/25878224/235059709-062cf237-5f9e-4ea0-8bdf-b74e7459d3a2.PNG)

![A- 3 sensor ](https://user-images.githubusercontent.com/25878224/235059716-a834701f-fe0b-4e9d-96f6-67001fc99398.PNG)

- Configure the docker image configuration file (DockerFile)

FROM python:3.7
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "main.py"]




# Linux B

# Linux C
