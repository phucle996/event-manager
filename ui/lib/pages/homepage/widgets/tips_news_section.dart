import 'package:flutter/material.dart';
import '../../../widgets/modern_section_card.dart';

class TipsNewsSection extends StatelessWidget {
  const TipsNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return ModernSectionCard(
      title: 'Tin tức & Gợi ý',
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.lightbulb_outline_rounded, color: color.primary),
            title: const Text('Mẹo tổ chức sự kiện hiệu quả'),
            subtitle: const Text('Tăng 20% lượt tham gia với 3 bước đơn giản!'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          ListTile(
            leading: Icon(Icons.campaign_rounded, color: color.secondary),
            title: const Text('Cập nhật tính năng mới'),
            subtitle: const Text('Thêm hệ thống quản lý khách mời tự động.'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
