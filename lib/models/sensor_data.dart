class SensorData {
  bool pir;
  bool rain;
  bool smoke;

  bool led;
  bool servo;
  bool buzzer;

  bool autoMode;

  SensorData({
    required this.pir,
    required this.rain,
    required this.smoke,
    required this.led,
    required this.servo,
    required this.buzzer,
    required this.autoMode,
  });
}