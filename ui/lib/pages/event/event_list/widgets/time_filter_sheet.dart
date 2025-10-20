import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Hiển thị bottom sheet chọn khoảng thời gian cho Event Filter
Future<String?> showTimeFilterSheet(BuildContext context) async {
  final color = Theme.of(context).colorScheme;
  final now = DateTime.now();
  DateTimeRange? selectedRange;

  final quickRanges = {
    'allTime': 'Tất cả',
    'thisWeek': 'Tuần này',
    'thisMonth': 'Tháng này',
    'thisYear': 'Năm nay',
    'custom': 'Tùy chọn...',
  };

  String selectedKey = 'thisMonth';

  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: color.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "📅 Bộ lọc thời gian",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Lựa chọn nhanh
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: quickRanges.entries.map((entry) {
                      final isSelected = entry.key == selectedKey;
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        selectedColor: color.primary.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? color.primary
                              : color.onSurfaceVariant,
                          fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        onSelected: (v) async {
                          if (!v) return;
                          setState(() => selectedKey = entry.key);

                          if (entry.key == 'custom') {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(now.year - 3),
                              lastDate: DateTime(now.year + 3),
                              initialDateRange: DateTimeRange(
                                start: DateTime(now.year, now.month, 1),
                                end: now,
                              ),
                            );
                            if (picked != null) {
                              selectedRange = picked;
                            }
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Hiển thị kết quả lựa chọn
                  if (selectedRange != null)
                    Center(
                      child: Text(
                        "Từ ${DateFormat('dd/MM').format(selectedRange!.start)} "
                            "đến ${DateFormat('dd/MM').format(selectedRange!.end)}",
                        style: TextStyle(
                          color: color.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Xác nhận
                  FilledButton.icon(
                    onPressed: () {
                      String label;
                      switch (selectedKey) {
                        case 'thisWeek':
                          label = 'Tuần này';
                          break;
                        case 'thisMonth':
                          label = 'Tháng này';
                          break;
                        case 'thisYear':
                          label = 'Năm nay';
                          break;
                        case 'custom':
                          if (selectedRange != null) {
                            label =
                            "Từ ${DateFormat('dd/MM').format(selectedRange!.start)} - "
                                "${DateFormat('dd/MM').format(selectedRange!.end)}";
                          } else {
                            label = 'Tùy chọn';
                          }
                          break;
                        default:
                          label = 'Tất cả thời gian';
                      }
                      Navigator.pop(context, label);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Xác nhận"),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
