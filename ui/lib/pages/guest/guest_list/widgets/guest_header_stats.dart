import 'package:flutter/material.dart';

class GuestHeaderStats extends StatelessWidget {
  final int total;
  final int attended;
  final int pending;
  final VoidCallback onAddGuest;

  const GuestHeaderStats({
    super.key,
    required this.total,
    required this.attended,
    required this.pending,
    required this.onAddGuest,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16), // ✅ cách lề trên dưới
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF32B768), Color(0xFF2BAA63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        // ✅ nội dung
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_alt_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Quản lý khách mời",
                    style: text.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: onAddGuest,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black26,
                  ),
                  child: const Text("Thêm mới"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ 3 thẻ thống kê
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  icon: Icons.groups_2_rounded,
                  label: "Tổng",
                  value: "$total",
                ),
                _buildStatCard(
                  icon: Icons.emoji_events_rounded,
                  label: "Tham dự",
                  value: "$attended",
                ),
                _buildStatCard(
                  icon: Icons.schedule_rounded,
                  label: "Chờ",
                  value: "$pending",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
