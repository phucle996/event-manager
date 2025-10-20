import 'package:flutter/material.dart';
import 'package:appflutter/pages/event/create/main_page.dart';
import 'package:appflutter/pages/guest/guest_new/guest_add_page.dart';
import 'package:appflutter/pages/report/report_page.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 🟢 Tạo sự kiện
          _QuickAction(
            icon: Icons.add_box_rounded,
            label: 'Tạo sự kiện',
            color: color.primary,
            onTap: () async {
              final created = await Navigator.push(
                context,
                _slidePage(const EventCreatePage()),
              );
              if (created != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 Sự kiện đã được tạo thành công!')),
                );
              }
            },
          ),

          // 🟢 Mời khách → sang trang tạo khách mời
          _QuickAction(
            icon: Icons.people_alt_rounded,
            label: 'Mời khách',
            color: color.primary,
            onTap: () {
              Navigator.push(context, _slidePage(const GuestAddPage()));
            },
          ),

          // 🟢 Báo cáo → sang trang thống kê
          _QuickAction(
            icon: Icons.bar_chart_rounded,
            label: 'Báo cáo',
            color: color.primary,
            onTap: () {
              Navigator.push(context, _slidePage(const ReportPage()));
            },
          ),

          // 🟢 Thông báo
          _QuickAction(
            icon: Icons.notifications_active,
            label: 'Thông báo',
            color: color.primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔔 Tính năng thông báo đang phát triển...')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🎬 Hàm tạo hiệu ứng chuyển trang slide mượt
  PageRouteBuilder _slidePage(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0); // trượt từ phải qua
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
