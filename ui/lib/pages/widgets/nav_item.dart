import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final double width;
  final Function(int) onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final bool isSelected = currentIndex == index;

    final Color baseColor =
    isSelected ? color.primary : color.onSurfaceVariant.withOpacity(0.5);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width, maxHeight: 60),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        splashColor: color.primary.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isSelected
                ? color.primary.withOpacity(0.12)
                : Colors.transparent,
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: color.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? LinearGradient(
                    colors: [
                      color.primary.withOpacity(0.85),
                      color.secondary.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  size: isSelected ? 24 : 22,
                  color: isSelected
                      ? Colors.white
                      : color.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? color.primary
                      : color.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.1,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
