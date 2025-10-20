import 'dart:ui';
import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info }

void showAppToast(
    BuildContext context,
    String msg, {
      ToastType type = ToastType.info,
    }) {
  final theme = Theme.of(context);
  final color = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  final overlay = Overlay.of(context);

  late Color bgStart, bgEnd, accent, iconColor;

  switch (type) {
    case ToastType.success:
      accent = color.secondary;
      bgStart = isDark ? const Color(0xFF064E3B) : const Color(0xFF34D399);
      bgEnd = isDark ? const Color(0xFF047857) : const Color(0xFF059669);
      iconColor = Colors.white;
      break;
    case ToastType.error:
      accent = color.error;
      bgStart = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFF87171);
      bgEnd = isDark ? const Color(0xFF991B1B) : const Color(0xFFEF4444);
      iconColor = Colors.white;
      break;
    case ToastType.warning:
      accent = const Color(0xFFF59E0B);
      bgStart = isDark ? const Color(0xFF78350F) : const Color(0xFFFBBF24);
      bgEnd = isDark ? const Color(0xFF92400E) : const Color(0xFFF59E0B);
      iconColor = Colors.black87;
      break;
    default:
      accent = color.primary;
      bgStart = isDark ? const Color(0xFF1E3A8A) : const Color(0xFF60A5FA);
      bgEnd = isDark ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB);
      iconColor = Colors.white;
  }

  final textColor =
  (type == ToastType.warning && !isDark) ? Colors.black87 : Colors.white;

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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: isDark
                          ? ImageFilter.blur(sigmaX: 8, sigmaY: 8)
                          : ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [bgStart, bgEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconForType(type),
                                color: iconColor, size: 22),
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
                                Icons.close_rounded,
                                size: 18,
                                color: textColor.withOpacity(0.8),
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
          ),
        ),
      );
    },
  );

  overlay.insert(entry);

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
