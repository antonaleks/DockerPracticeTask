- Install on each virtual machine docker and docker-compose.

![1- version A](https://user-images.githubusercontent.com/25878224/234697074-ee27f537-754b-4935-a552-43f76bdc7843.PNG)

![1- version B](https://user-images.githubusercontent.com/25878224/234697168-816b99c6-c84f-45f1-a5b7-a51d7c514424.PNG)

![1- version c](https://user-images.githubusercontent.com/25878224/234697182-737a155a-0f8f-4ab9-84e7-6c8fa20391fb.PNG)

-  Create the four Sensors classes (Temperature, Pressure, Current, Humidity) by module "sensor.py"

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

- Build the docker image with the following command:

      sudo docker build -t souhair/simulator .
      
![2-3](https://user-images.githubusercontent.com/25878224/235060282-8ecb0cc6-78f3-4a1d-afaa-15782bc6011e.PNG)

- Download mosquitto broker, create mosquitto.conf file

![B 1 mosq](https://user-images.githubusercontent.com/25878224/235062194-88a0e5df-c59e-4d56-8648-84c3127bdc53.PNG)

- Start a container with a binding to a port and loading a conf file into the system

![B 2  mosq](https://user-images.githubusercontent.com/25878224/235062613-a823d3e5-bbd6-4e00-8ce1-6488e5acbe8e.PNG)

- Let's see when running this command to test temperature sensor: 

![3- 6 test sensor](https://user-images.githubusercontent.com/25878224/235064111-59c08193-60a6-4e1c-9f97-717ef6a3a63d.PNG)

![3-1 test sensor](https://user-images.githubusercontent.com/25878224/235064130-5a82d272-818a-49ae-8d53-3e826f6a8cc0.PNG)

![3-5 test sensor](https://user-images.githubusercontent.com/25878224/235064223-3cd49436-a18d-48c3-95dd-cdaabfba1424.PNG)

- And check with mqtt explorer

![5-1 mqtt](https://user-images.githubusercontent.com/25878224/235063223-29384927-36ec-483a-9fc8-d1ceedeb4c9f.PNG)


- Pushing the Image to DockerHub

![4- 1 push image](https://user-images.githubusercontent.com/25878224/235063094-cf5382fc-31ec-4e24-bb40-2c84a3a6b112.PNG) 

- Now test all sensors:

![3-2 tesetsensor](https://user-images.githubusercontent.com/25878224/235063689-efbb0454-b255-4288-be44-e04beb389fe8.PNG)

![3-4 tesetsensor](https://user-images.githubusercontent.com/25878224/235064211-247cd9fa-c7db-4bc4-9165-26b15aa9bb3c.PNG)

![3-2 -1 tesetsensor](https://user-images.githubusercontent.com/25878224/235063939-1f29b84a-4c0a-48d7-a14a-d1f702212b1b.PNG)


- Check with mqtt explorer

![5-3 mqtt](https://user-images.githubusercontent.com/25878224/235063315-6e97974e-e161-4947-bbc2-f03dd62ec598.PNG)

- After that, we create a docker-compose file:

![4- 2 dockercompose](https://user-images.githubusercontent.com/25878224/235065175-017622e7-1f0a-4d53-8530-821f787057d6.PNG)

![4- 3 dockercompose](https://user-images.githubusercontent.com/25878224/235065490-44a39c93-4680-4972-ba9f-0e221ed66b24.PNG)

 In Linux A: 
- Influxdb 
Run a container with a database with an attached volume (version 1.8)

![influxdb 1](https://user-images.githubusercontent.com/25878224/235066231-131e54e7-93a2-429a-a40a-985b413cb592.PNG)

- Telegraf - configration file

![telegraf conf](https://user-images.githubusercontent.com/25878224/235066474-db765f99-3908-4e73-91b8-e5f41a9dab50.PNG)

- Now we have:

![f1](https://user-images.githubusercontent.com/25878224/235067314-9b0fc5e7-03e6-416f-b010-4e83445e7e5f.PNG)

![f2](https://user-images.githubusercontent.com/25878224/235067324-c976bfbf-e29b-4f4d-8f3a-6e31e4770036.PNG)

![f3](https://user-images.githubusercontent.com/25878224/235067345-81b4ed28-8be9-4f21-a521-2d03533cb9f8.PNG)

- Grafana on port 3000

![grafana 1- 1 ](https://user-images.githubusercontent.com/25878224/235066132-86838126-656b-4e4c-93b2-56bb8ef54275.PNG)

![grafana 2](https://user-images.githubusercontent.com/25878224/235066148-0315a22a-b44e-4f40-9255-a9e12daf1329.PNG)

![g1](https://user-images.githubusercontent.com/25878224/235069233-6ff21b4a-5ebe-4417-bb44-56814e8efde2.PNG)

![g2](https://user-images.githubusercontent.com/25878224/235069252-7aeb372c-54b7-4cc8-bd3f-8a4306105502.PNG)

