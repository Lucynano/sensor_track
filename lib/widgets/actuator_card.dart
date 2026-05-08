import 'package:flutter/material.dart';

class ActuatorCard extends StatelessWidget {
  final String name;
  final bool value;
  final bool autoMode;
  final IconData icon;
  final Function(bool) onChanged;

  const ActuatorCard({
    super.key,
    required this.name,
    required this.value,
    required this.autoMode,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: value ? Colors.green : Colors.grey,  
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(autoMode ? "Contrôle automatique" : "Contrôle manuel"),
        trailing: Switch(
          value: value, 
          onChanged: autoMode ? null : onChanged
        ),
      ),
    );    
  }
}