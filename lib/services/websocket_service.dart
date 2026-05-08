import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketService {
  WebSocketChannel? channel;

  void connect(String ip) {
    channel = WebSocketChannel.connect(
      Uri.parse("ws://$ip:81"),
    );
  }

  Stream get stream {
    return channel!.stream;
  }

  void sendCommand(String device, bool state) {
    final data = {
      "device": device,
      "state": state ? 1 : 0,
    };

    channel?.sink.add(jsonEncode(data));
  }

  void changeMode(bool autoMode) {
    final data = {
      "mode": autoMode ? "AUTO" : "MANUAL",
    };

    channel?.sink.add(jsonEncode(data));
  }

  void disconnect() {
    channel?.sink.close();
  }
}