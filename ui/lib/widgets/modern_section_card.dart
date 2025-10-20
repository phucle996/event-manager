import 'package:flutter/material.dart';

/// A modern, soft-looking section card.
/// Inspired by fintech / banking apps (neumorphic + subtle gradient).
class ModernSectionCard extends StatelessWidget {
  const ModernSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actions,
    this.padding = const EdgeInsets.all(24),
    this.spacing = 20,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final headerActions = actions;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
          colors: [
            color.surface,
            color.surfaceVariant.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF9FAFD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark) ...[
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 6,
              offset: const Offset(-4, -4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
          ] else
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE9ECF2),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || subtitle != null || headerActions != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: isDark
                                  ? color.primary.withOpacity(0.9)
                                  : const Color(0xFF102B4C),
                            ),
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color.onSurfaceVariant.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (headerActions != null && headerActions.isNotEmpty)
                    Wrap(spacing: 8, runSpacing: 8, children: headerActions),
                ],
              ),
              SizedBox(height: spacing),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
