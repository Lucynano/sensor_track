#include <WiFi.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>

const char* ssid = "wifi_name";
const char* password = "password";

// Sensors
#define RAIN_PIN 5
#define MQ2_PIN 6
#define PIR_PIN 10

// Actuors
#define LED_PIN 7
#define BUZZER_PIN 8
#define SERVO_PIN 9

WebSocketsServer webSocket(81);
Servo roofServo;

// State
bool autoMode = true;

bool rainState = false;
bool pirState = false;
bool smokeState = false;

bool lastRainState = false;
bool lastPirState = false;
bool lastSmokeState = false;

bool servoState = false;
bool ledState = false;
bool buzzerState = false;


const int SERVO_OPEN = 0;
const int SERVO_CLOSE = 90;

void applyActuators() {

  roofServo.write(
    servoState ? SERVO_CLOSE : SERVO_OPEN
  );

  digitalWrite(
    LED_PIN,
    ledState ? HIGH : LOW
  );

  digitalWrite(
    BUZZER_PIN,
    buzzerState ? HIGH : LOW
  );
}

bool readRain() {

  int count = 0;

  for (int i = 0; i < 5; i++) {

    if (digitalRead(RAIN_PIN) == LOW) {
      count++;
    }

    delay(10);
  }

  return count >= 3;
}

bool readPir() {

  int count = 0;

  for (int i = 0; i < 5; i++) {

    if (digitalRead(PIR_PIN) == HIGH) {
      count++;
    }

    delay(10);
  }

  return count >= 3;
}

bool readSmoke() {

  int count = 0;

  for (int i = 0; i < 5; i++) {

    if (digitalRead(MQ2_PIN) == LOW) {
      count++;
    }

    delay(10);
  }

  return count >= 3;
}

// Send to flutter
void sendData(String message = "") {

  StaticJsonDocument<384> doc;

  doc["mode"] = autoMode ? "AUTO" : "MANUAL";

  doc["rain"] = rainState ? 1 : 0;
  doc["pir"] = pirState ? 1 : 0;
  doc["smoke"] = smokeState ? 1 : 0;

  doc["servo"] = servoState ? 1 : 0;
  doc["led"] = ledState ? 1 : 0;
  doc["buzzer"] = buzzerState ? 1 : 0;

  doc["message"] = message;

  String json;

  serializeJson(doc, json);

  webSocket.broadcastTXT(json);

  Serial.println(json);
}

// Mode auto
void automaticControl() {

  if (!autoMode) return;
  
  rainState = readRain();
  pirState = readPir();
  smokeState = readSmoke();

  Serial.print("MODE = ");
  Serial.print(autoMode ? "AUTO" : "MANUAL");

  Serial.print(" || Pluie = ");
  Serial.print(rainState);

  Serial.print(" || PIR = ");
  Serial.print(pirState);

  Serial.print(" || Fumee = ");
  Serial.println(smokeState);

  // Rain
  if (rainState != lastRainState) {

    servoState = rainState;

    applyActuators();

    sendData(
      rainState
        ? "Pluie détectée, toit fermé"
        : "Pluie arrêtée, toit ouvert"
    );

    lastRainState = rainState;
  }

  // PIR
  if (pirState != lastPirState) {

    ledState = pirState;

    applyActuators();

    sendData(
      pirState
        ? "Mouvement détecté, LED allumée"
        : "Aucun mouvement, LED éteinte"
    );

    lastPirState = pirState;
  }

  // MQ2
  if (smokeState != lastSmokeState) {

    buzzerState = smokeState;

    applyActuators();

    sendData(
      smokeState
        ? "Fumée détectée, buzzer activé"
        : "Fumée absente, buzzer désactivé"
    );

    lastSmokeState = smokeState;
  }

  delay(300);
}

void handleCommand(String payload) {

  Serial.println(" JSON RECEIVES ");
  Serial.println(payload);

  StaticJsonDocument<256> doc;

  DeserializationError error =
      deserializeJson(doc, payload);

  if (error) {

    Serial.println("JSON invalid");

    return;
  }

  // Mode
  if (doc.containsKey("mode") &&
      doc["mode"].is<String>()) {

    String mode =
        doc["mode"].as<String>();

    if (mode == "AUTO" ||
        mode == "MANUAL") {

      autoMode = mode == "AUTO";

      sendData(
        autoMode
          ? "Mode automatique activé"
          : "Mode manuel activé"
      );
    }

    return;
  }

  // Manual mode
  if (!autoMode &&
      doc.containsKey("device") &&
      doc.containsKey("state")) {

    String device = doc["device"];

    int state = doc["state"];

    // Servo
    if (device == "servo") {

      servoState = state == 1;

      applyActuators();

      sendData(
        servoState
          ? "Toit fermé manuellement"
          : "Toit ouvert manuellement"
      );
    }

    // LED
    if (device == "led") {

      ledState = state == 1;

      applyActuators();

      sendData(
        ledState
          ? "LED allumée manuellement"
          : "LED éteinte manuellement"
      );
    }

    // BUZZER 
    if (device == "buzzer") {

      buzzerState = state == 1;

      applyActuators();

      sendData(
        buzzerState
          ? "Buzzer activé manuellement"
          : "Buzzer désactivé manuellement"
      );
    }
  }
}

// WEBSOCKET 
void webSocketEvent(
  uint8_t num,
  WStype_t type,
  uint8_t* payload,
  size_t length
) {

  if (type == WStype_CONNECTED) {

    Serial.println("Flutter connecté");

    sendData(
      "Application connectée à ESP32"
    );
  }

  if (type == WStype_TEXT) {

    handleCommand(
      String((char*)payload)
    );
  }
}

void setup() {

  Serial.begin(115200);

  pinMode(RAIN_PIN, INPUT);
  pinMode(PIR_PIN, INPUT);
  pinMode(MQ2_PIN, INPUT);

  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  roofServo.setPeriodHertz(50);

  roofServo.attach(
    SERVO_PIN,
    500,
    2400
  );

  applyActuators();

  // Wifi
  WiFi.begin(ssid, password);

  Serial.println("Connexion WiFi...");

  while (WiFi.status() != WL_CONNECTED) {

    delay(500);

    Serial.print(".");
  }

  Serial.println();

  Serial.print("IP ESP32 : ");

  Serial.println(WiFi.localIP());

  // WEBSOCKET 
  webSocket.begin();

  webSocket.onEvent(webSocketEvent);

  Serial.println(
    "WebSocket lancé sur port 81"
  );
  Serial.println("Calibrage...");
  delay(60000);
}

void loop() {

  webSocket.loop();

  automaticControl();
}