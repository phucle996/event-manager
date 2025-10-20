import 'dart:ui';
import 'package:appflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Widget child;
  final PreferredSizeWidget? Function(BuildContext)? appBarBuilder;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.child,
    this.appBarBuilder,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isEventTab = widget.selectedIndex == 2;
    final appLocalizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: widget.appBarBuilder?.call(context),
      body: widget.child,

      floatingActionButton: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color.primary.withOpacity(0.95),
                color.secondary.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () => widget.onItemTapped(2),
            child: const Icon(Icons.event, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🌈 Modern floating nav bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: isDark
                      ? color.surface.withOpacity(0.75)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 60) / 4;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          icon: Icons.home_rounded,
                          label: appLocalizations.home,
                          index: 0,
                          currentIndex: widget.selectedIndex,
                          onTap: widget.onItemTapped,
                          width: itemWidth,
                        ),
                        _NavItem(
                          icon: Icons.people_rounded,
                          label: appLocalizations.guests,
                          index: 1,
                          currentIndex: widget.selectedIndex,
                          onTap: widget.onItemTapped,
                          width: itemWidth,
                        ),
                        const SizedBox(width: 48), // chừa chỗ cho FAB
                        _NavItem(
                          icon: Icons.bar_chart_rounded,
                          label: appLocalizations.reports,
                          index: 3,
                          currentIndex: widget.selectedIndex,
                          onTap: widget.onItemTapped,
                          width: itemWidth,
                        ),
                        _NavItem(
                          icon: Icons.person_rounded,
                          label: appLocalizations.profile,
                          index: 4,
                          currentIndex: widget.selectedIndex,
                          onTap: widget.onItemTapped,
                          width: itemWidth,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🌟 Fintech Nav Item with gradient + smooth animation
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;
  final double width;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.width,
  });

  bool get selected => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isSelected = selected;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTap(index),
      splashColor: color.primary.withOpacity(0.1),
      child: SizedBox(
        width: width,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(8),
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
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : color.onSurfaceVariant.withOpacity(0.7),
                size: isSelected ? 24 : 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? color.primary
                    : color.onSurfaceVariant.withOpacity(0.8),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
