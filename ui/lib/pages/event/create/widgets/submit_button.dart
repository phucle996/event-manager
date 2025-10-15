import 'package:flutter/material.dart';

class EventSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String? label; // ✅ 1. Thêm tham số label tùy chọn

  const EventSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label, // ✅ 2. Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: const Icon(Icons.save),
        // ✅ 3. Sử dụng label tùy chỉnh, fallback về giá trị mặc định
        label: isLoading
            ? const Text("Đang xử lý...")
            : Text(label ?? "Tạo sự kiện"),
      ),
    );
  }
}
