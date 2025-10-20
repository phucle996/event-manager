import 'package:flutter/material.dart';

class EventTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  const EventTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: (v) =>
          v == null || v.isEmpty ? "⚠️ Không được để trống" : null,
    );
  }
}
