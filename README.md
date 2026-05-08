# sensor_track

Smart Mobile System for Monitoring and Controlling IoT Sensors


## Overview

This project is a mobile IoT monitoring and control system using Flutter and ESP32.
The system monitors environmental sensors in real time and controls actuators automatically or manually through a mobile application using WebSocket communication.


## Features

  - Real-time sensor monitoring
  - Automatic and manual control modes
  - Remote actuator control from mobile app
  - Real-time notifications
  - Wi-Fi communication using WebSocket


## Sensors

  - Rain Sensor
  - PIR Motion Sensor (HS-S38A Human body sensor)
  - MQ2 Smoke/Gas Sensor


## Actuators

  - MG90S Servo Motor
  - LED
  - Buzzer


## Technologies Used

### Software

  - Flutter
  - Dart
  - Arduino IDE

### Hardware

  - ESP32-S3
  - Arduino Uno (servo power supply)
  - Breadbord
  - Jumper wires
  - Resistor 220 Ohm (for LED)


## System Architecture

```bash
Sensors ---> ESP32 ---> WebSocket ---> Flutter App
                   <--- Commands <---
```


## Installation

```bash
git clone git@github.com:Lucynano/sensor_track.git
mkdir sensor_track
```

### Flutter

```bash
  flutter pub get
  flutter run
```

### ESP32
  1. Open the Arduino code in Arduino IDE
  2. Install required libraries:
     - ESP32Servo
     - ArduinoJson
     - WebSocketsServer
  3. Upload the code (sensor_track_esp32/sensor_track.ino) to ESP32


## Wi-Fi Configuration

```bash
const char* ssid = "wifi_name";
const char* password = "password";
```


## Screenshots app

<img width="1080" height="2083" alt="CXASzdah" src="https://github.com/user-attachments/assets/c9c64af6-b604-47e7-b0c2-3512cacfd31b" />
<br>
<br>
<img width="1080" height="1859" alt="4bJ0ewsl" src="https://github.com/user-attachments/assets/1a1b6d56-3ce7-4eae-8e4a-bde4f7a8ecad" />


## Hardware images

<img width="2048" height="2048" alt="PdhSZf_O" src="https://github.com/user-attachments/assets/f4058b29-d1f5-4d2f-9346-ce0cce727680" />
<br>
<br>
<img width="1920" height="1920" alt="PUNrcPwY" src="https://github.com/user-attachments/assets/92c17208-8d7c-43f4-b539-3179a7cb04ee" />
<br>
<br>
https://github.com/user-attachments/assets/f6fce4a0-0289-477f-9b26-504fe7005ea7

https://github.com/user-attachments/assets/27764628-52f0-47b8-96a7-63563dd4e52a









