import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String name;
  final bool isActive;
  final IconData icon;

  const SensorCard({
    super.key,
    required this.name,
    required this.isActive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isActive ? "Activé" : "Désactivé",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}