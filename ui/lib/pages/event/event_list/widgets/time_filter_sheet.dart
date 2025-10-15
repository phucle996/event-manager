import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<String?> showTimeFilterSheet(BuildContext context) async {
  final now = DateTime.now();
  DateTimeRange tempRange = DateTimeRange(
    start: now.subtract(const Duration(days: 7)),
    end: now,
  );

  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "📆 Chọn khoảng thời gian",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  CalendarDatePicker(
                    initialDate: now,
                    firstDate: DateTime(now.year - 3),
                    lastDate: DateTime(now.year + 3),
                    onDateChanged: (date) {
                      tempRange = DateTimeRange(start: date, end: date);
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () {
                        final label =
                            "Từ ${DateFormat('dd/MM').format(tempRange.start)} - ${DateFormat('dd/MM').format(tempRange.end)}";
                        Navigator.pop(context, label);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Xác nhận"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
