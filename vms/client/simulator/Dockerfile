FROM python:alpine3.19
WORKDIR /app
RUN pip install paho_mqtt==1.6.1
COPY . .
CMD ["python", "main.py"]
