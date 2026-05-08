import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../models/notification_model.dart';
import '../widgets/sensor_card.dart';
import '../widgets/actuator_card.dart';
import 'notification_screen.dart';
import '../services/websocket_service.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SensorData data = SensorData(
    pir: false,
    rain: false,
    smoke: false,
    led: false,
    servo: false,
    buzzer: false,
    autoMode: true,
  );

  List<NotificationModel> notifications = [];

  int unreadCount = 0;

  final WebsocketService ws = WebsocketService();

  @override
  void initState() {
    super.initState();

    ws.connect("192.168.243.66");

    ws.stream.listen((message) {
      handleEsp32Data(message);
    });
  }

  @override
  void dispose() {
    ws.disconnect();
    super.dispose();
  }

  String getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

void handleEsp32Data(String message) {
  final json = jsonDecode(message);

  setState(() {
    if (json["rain"] != null) {
      data.rain = json["rain"] == 1;
    }

    if (json["pir"] != null) {
      data.pir = json["pir"] == 1;
    }

    if (json["smoke"] != null) {
      data.smoke = json["smoke"] == 1;
    }

    if (json["servo"] != null) {
      data.servo = json["servo"] == 1;
    }

    if (json["led"] != null) {
      data.led = json["led"] == 1;
    }

    if (json["buzzer"] != null) {
      data.buzzer = json["buzzer"] == 1;
    }

    if (json["mode"] != null) {
      data.autoMode = json["mode"] == "AUTO";
    }
  });

  if (json["message"] != null && json["message"] != "") {
    addNotification(json["message"]);
  }
}

  void addNotification(String message) {
    setState(() {
      notifications.insert(
        0,
        NotificationModel(title: message, time: getCurrentTime()),
      );
      unreadCount++;
    });
  }

  void simulatePir(bool detecteed) {
    setState(() {
      data.pir = detecteed;
      data.led = detecteed;
    });

    addNotification(
      detecteed
          ? "Mouvement détecté, LED allumée"
          : "Aucun mouvement, LED éteinte",
    );
  }

  void simulateRain(bool detecteed) {
    setState(() {
      data.rain = detecteed;
      data.servo = detecteed;
    });

    addNotification(
      detecteed ? "Pluie détectée, toit fermé" : "Pluie arrêtée, toit ouvert",
    );
  }

  void simulateSmoke(bool detecteed) {
    setState(() {
      data.smoke = detecteed;
      data.buzzer = detecteed;
    });

    addNotification(
      detecteed
          ? "Alerte fumée détectée, buzzer activé"
          : "Fumée absente, buzzer désactivé",
    );
  }

  void resetSensors() {
    setState(() {
      data.pir = false;
      data.rain = false;
      data.smoke = false;
    });
    addNotification("Capteurs réinitialisées");
  }

  void changeMode(bool value) {
    setState(() {
      data.autoMode = value;
    });

    ws.changeMode(value); // IMPORTANT

    addNotification(value ? "Mode automatique activé" : "Mode manuel activé");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APPBAR
      appBar: AppBar(
        title: Text("Sensor Track"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () {
                  setState(() {
                    unreadCount = 0;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NotificationScreen(notifications: notifications),
                    ),
                  );
                },
              ),
              // BADGE
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      // BODY
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text(
                "Mode automatique",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data.autoMode ? "AUTO" : "MANUEL"),
              value: data.autoMode,
              onChanged: changeMode,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Capteurs",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          SensorCard(
            name: "Capteur PIR",
            isActive: data.pir,
            icon: Icons.directions_walk,
          ),
          SensorCard(
            name: "Capteur de pluie",
            isActive: data.rain,
            icon: Icons.water_drop,
          ),
          SensorCard(
            name: "Capteur de fumée",
            isActive: data.smoke,
            icon: Icons.local_fire_department,
          ),

          const SizedBox(height: 20),

          const Text(
            "Actionneurs",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ActuatorCard(
            name: "LED",
            value: data.led,
            autoMode: data.autoMode,
            icon: Icons.lightbulb,
            onChanged: (value) {
              setState(() {
                data.led = value;
              });
              
              ws.sendCommand("led", value);

              addNotification(value ? "LED allumée" : "LED éteinte");
            },
          ),

          ActuatorCard(
            name: "Servomoteur",
            value: data.servo,
            autoMode: data.autoMode,
            icon: Icons.roofing,
            onChanged: (value) {
              setState(() {
                data.servo = value;
              });

              ws.sendCommand("servo", value);

              addNotification(value ? "Toit fermé" : "Toit ouvert");
            },
          ),

          ActuatorCard(
            name: "Buzzer",
            value: data.buzzer,
            autoMode: data.autoMode,
            icon: Icons.volume_up,
            onChanged: (value) {
              setState(() {
                data.buzzer = value;
              });

              ws.sendCommand("buzzer", value);

              addNotification(value ? "Buzzer activé" : "Buzzer désactivé");
            },
          ),

          const SizedBox(height: 20),

          const Text(
            "Simulation ESP32",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () => simulatePir(true),
            child: const Text("PIR détecte"),
          ),
          ElevatedButton(
            onPressed: () => simulatePir(false),
            child: const Text("PIR ne détecte plus"),
          ),
          ElevatedButton(
            onPressed: () => simulateRain(true),
            child: const Text("Pluie détectée"),
          ),
          ElevatedButton(
            onPressed: () => simulateRain(false),
            child: const Text("Pluie arrêtée"),
          ),
          ElevatedButton(
            onPressed: () => simulateSmoke(true),
            child: const Text("Fumée détectée"),
          ),
          ElevatedButton(
            onPressed: () => simulateSmoke(false),
            child: const Text("Fumée absente"),
          ),
          ElevatedButton(
            onPressed: resetSensors,
            child: const Text("Réinitialiser capteurs"),
          ),
        ],
      ),
    );
  }
}
