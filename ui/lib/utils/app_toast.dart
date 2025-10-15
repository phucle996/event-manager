import 'package:flutter/material.dart';

// Enum để xác định loại toast, có thể dùng ở mọi nơi
enum ToastType { success, error, warning, info }

/// Hiển thị một toast message tùy chỉnh, trượt từ trên xuống.
/// [context]: BuildContext của màn hình hiện tại.
/// [msg]: Nội dung tin nhắn cần hiển thị.
/// [type]: Loại toast (success, error, warning, info) để quyết định màu sắc và icon.
void showAppToast(
  BuildContext context,
  String msg, {
  ToastType type = ToastType.info,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final overlay = Overlay.of(context);

  // 🎨 Màu mạnh, rõ, có gradient nhẹ
  late Color bgStart, bgEnd, accent, iconColor;
  switch (type) {
    case ToastType.success:
      accent = const Color(0xFF10B981);
      bgStart = isDark ? const Color(0xFF064E3B) : const Color(0xFF34D399);
      bgEnd = isDark ? const Color(0xFF047857) : const Color(0xFF059669);
      iconColor = Colors.white;
      break;
    case ToastType.error:
      accent = const Color(0xFFEF4444);
      bgStart = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFB7185);
      bgEnd = isDark ? const Color(0xFF991B1B) : const Color(0xFFF43F5E);
      iconColor = Colors.white;
      break;
    case ToastType.warning:
      accent = const Color(0xFFF59E0B);
      bgStart = isDark ? const Color(0xFF78350F) : const Color(0xFFFBBF24);
      bgEnd = isDark ? const Color(0xFF92400E) : const Color(0xFFF59E0B);
      iconColor = Colors.black87;
      break;
    default:
      accent = const Color(0xFF3B82F6);
      bgStart = isDark ? const Color(0xFF1E3A8A) : const Color(0xFF60A5FA);
      bgEnd = isDark ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB);
      iconColor = Colors.white;
  }

  final textColor = (type == ToastType.warning && !isDark)
      ? Colors.black87
      : Colors.white;
  bool visible = true;
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (ctx) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: AnimatedSlide(
              offset: visible ? Offset.zero : const Offset(0, -0.2),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [bgStart, bgEnd]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(iconForType(type), color: iconColor, size: 22),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            msg,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (!visible) return;
                            visible = false;
                            entry.markNeedsBuild();
                            Future.delayed(
                              const Duration(milliseconds: 320),
                              entry.remove,
                            );
                          },
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);

  // Tự động ẩn
  Future.delayed(const Duration(milliseconds: 3500), () {
    if (!visible) return;
    visible = false;
    entry.markNeedsBuild();
    Future.delayed(const Duration(milliseconds: 320), entry.remove);
  });
}

IconData iconForType(ToastType type) {
  switch (type) {
    case ToastType.success:
      return Icons.check_circle_rounded;
    case ToastType.error:
      return Icons.error_outline_rounded;
    case ToastType.warning:
      return Icons.warning_amber_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}
