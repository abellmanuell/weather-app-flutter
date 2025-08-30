import 'package:flutter/material.dart';

class AdditionalInformation extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdditionalInformation({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 16),
          Text(label),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
