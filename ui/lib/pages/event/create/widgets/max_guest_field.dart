import 'package:flutter/material.dart';

class EventMaxGuestField extends StatelessWidget {
  final TextEditingController controller;
  const EventMaxGuestField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Số lượng khách tối đa",
        prefixIcon: Icon(Icons.people),
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Nhập số lượng khách";
        final n = int.tryParse(v);
        if (n == null || n <= 0) return "Giá trị không hợp lệ";
        return null;
      },
    );
  }
}
