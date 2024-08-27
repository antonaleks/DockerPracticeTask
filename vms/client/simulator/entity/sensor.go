package entity

import (
	"encoding/json"
	"log"
	"math"
	"math/rand"
)

type Sensor interface {
	GenerateNewValue()
	GetData() float64
	String() string
	GetName() string
	GetType() string
}

type BaseSensor struct {
	Name  string
	Value float64
	Type  string
}

func (s *BaseSensor) GenerateNewValue() {}

func (s *BaseSensor) GetData() float64 {
	return s.Value
}
func (s *BaseSensor) GetType() string {
	return s.Type
}
func (s *BaseSensor) GetName() string {
	return s.Name
}

func (s *BaseSensor) String() string {
	data, _ := json.Marshal(s)
	return string(data)
}

type Temperature struct {
	BaseSensor
	Step float64
}

func NewTemperature(name string) *Temperature {
	return &Temperature{
		BaseSensor: BaseSensor{Name: name, Type: "temperature"},
		Step:       25,
	}
}

func (t *Temperature) GenerateNewValue() {
	t.Value = rand.Float64() + t.Step
}

type Pressure struct {
	BaseSensor
	Step float64
}

func NewPressure(name string) *Pressure {
	return &Pressure{
		BaseSensor: BaseSensor{Name: name, Type: "pressure"},
		Step:       55,
	}
}

func (p *Pressure) GenerateNewValue() {
	p.Value = rand.Float64() + p.Step - 56.48 + 25*7
}

type Current struct {
	BaseSensor // Встраивание BaseSensor
	Step       float64
}

func NewCurrent(name string) *Current {
	return &Current{
		BaseSensor: BaseSensor{Name: name, Type: "current"},
		Step:       0,
	}
}

func (c *Current) GenerateNewValue() {
	c.Value = math.Sin(c.Step)
	c.Step++
}

type Humidity struct {
	BaseSensor
}

func NewHumidity(name string) *Humidity {
	return &Humidity{
		BaseSensor: BaseSensor{Name: name, Type: "humidity"},
	}
}

func (h *Humidity) GenerateNewValue() {
	h.Value = rand.Float64() * 100
}

type Light struct {
	BaseSensor
}

func NewLight(name string) *Humidity {
	return &Humidity{
		BaseSensor: BaseSensor{Name: name, Type: "light"},
	}
}

func (h *Light) GenerateNewValue() {
	h.Value = rand.Float64() * 1000
}

func SensorFactory(typeS string, name string) Sensor {
	switch typeS {
	case "temperature":
		return NewTemperature(name)
	case "pressure":
		return NewPressure(name)
	case "current":
		return NewCurrent(name)
	case "humidity":
		return NewHumidity(name)
	case "light":
		return NewLight(name)
	default:
		log.Fatal("No such type of sensor")
		return nil
	}
}
