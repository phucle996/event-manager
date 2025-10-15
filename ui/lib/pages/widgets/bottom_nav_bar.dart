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

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isEventTab = widget.selectedIndex == 2;
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      // 🔘 AppBar và body do cha truyền vào
      appBar: widget.appBarBuilder?.call(context),
      body: widget.child,

      // 🔘 Floating Action Button trung tâm
      floatingActionButton: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: FloatingActionButton(
          elevation: isEventTab ? 8 : 4,
          shape: const CircleBorder(),
          backgroundColor: isEventTab ? color.primary : color.primaryContainer,
          foregroundColor: isEventTab
              ? color.onPrimary
              : color.onPrimaryContainer,
          onPressed: () {
            // ✅ Khi nhấn, chuyển sang tab "Sự kiện" (index = 2)
            widget.onItemTapped(2);
          },
          child: const Icon(Icons.event, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🧱 BottomAppBar với notch cho FAB
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomAppBar(
          color: color.surfaceContainerHighest,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          padding: EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 48) / 4;
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
    );
  }
}

/// 🌈 Widget Nav Item riêng, có hiệu ứng animation & ripple
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
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(index),
      child: SizedBox(
        width: width,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: isSelected ? 1.3 : 1.0,
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                color: isSelected ? color.primary : color.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? color.primary
                    : color.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
