import 'package:flutter/material.dart';

/// Provides a responsive background that automatically adapts
/// to light and dark theme modes.
class AppPageBackground extends StatelessWidget {
  const AppPageBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    this.maxContentWidth = 1100,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
          colors: [
            color.background,
            color.surfaceVariant.withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
            : const LinearGradient(
          colors: [
            Color(0xFFF8FAFF),
            Color(0xFFF3F6FB),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
