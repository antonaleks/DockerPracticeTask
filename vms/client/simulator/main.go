package main

import (
	"encoding/json"
	"fmt"
	mqtt "github.com/eclipse/paho.mqtt.golang"
	"math/rand"
	"os"
	"sensor/entity"
	"strconv"
	"time"
)

func main() {
	rand.Seed(time.Now().UnixNano())
	broker := "localhost"
	if simHost := os.Getenv("SIM_HOST"); simHost != "" {
		broker = simHost
	}
	port := 1883
	if simPort := os.Getenv("SIM_PORT"); simPort != "" {
		if p, err := strconv.Atoi(simPort); err == nil {
			port = p
		}
	}
	name := "sensor"
	if simName := os.Getenv("SIM_NAME"); simName != "" {
		name = simName
	}
	period := 1
	if simPeriod := os.Getenv("SIM_PERIOD"); simPeriod != "" {
		if p, err := strconv.Atoi(simPeriod); err == nil {
			period = p
		}
	}
	typeSim := "temperature"
	if simType := os.Getenv("SIM_TYPE"); simType != "" {
		typeSim = simType
	}

	sensor := entity.SensorFactory(typeSim, name)
	fmt.Println(sensor)
	opts := mqtt.NewClientOptions().AddBroker(fmt.Sprintf("tcp://%s:%d", broker, port)).SetClientID(sensor.GetName())
	fmt.Printf("%+v", opts)
	opts.OnConnect = func(c mqtt.Client) {
		fmt.Println("Connected to MQTT broker")
	}
	client := mqtt.NewClient(opts)
	fmt.Println(port)
	fmt.Println(broker)
	if token := client.Connect(); token.Wait() && token.Error() != nil {
		fmt.Println("ERROR")
		fmt.Println(token.Error())
		return
	}
	defer client.Disconnect(250)

	for {
		sensor.GenerateNewValue()
		data, _ := json.Marshal(sensor)
		client.Publish("sensors/"+sensor.GetType()+"/"+sensor.GetName(), 0, false, data)
		time.Sleep(time.Duration(period) * time.Second)
	}
}
