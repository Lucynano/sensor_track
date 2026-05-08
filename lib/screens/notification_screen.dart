import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationScreen({
    super.key, 
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text("Aucune notification"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(notif.title),
                    subtitle: Text(notif.time),
                  ),
                );
              },
            ),
    );
  }
}