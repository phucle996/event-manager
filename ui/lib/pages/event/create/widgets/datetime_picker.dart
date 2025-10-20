import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDateTimePicker extends StatefulWidget {
  final String label;
  final IconData icon;
  final Function(DateTime, TimeOfDay) onPicked;

  const EventDateTimePicker({
    super.key,
    required this.label,
    required this.icon,
    required this.onPicked,
  });

  @override
  State<EventDateTimePicker> createState() => _EventDateTimePickerState();
}

class _EventDateTimePickerState extends State<EventDateTimePicker> {
  DateTime? _date;
  TimeOfDay? _time;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    // 🗓️ Chọn ngày
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: "Chọn ngày tổ chức",
      confirmText: "Xác nhận",
      cancelText: "Hủy",
    );
    if (pickedDate == null) return;

    // ⏰ Chọn giờ và phút
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      helpText: "Chọn giờ bắt đầu",
      confirmText: "Xác nhận",
      cancelText: "Hủy",
    );
    if (pickedTime == null) return;

    setState(() {
      _date = pickedDate;
      _time = pickedTime;
    });

    widget.onPicked(pickedDate, pickedTime);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    final display = _date == null
        ? widget.label
        : "${DateFormat('dd/MM/yyyy').format(_date!)} - ${_time != null ? _formatTime(_time!) : ''}";

    return GestureDetector(
      onTap: _pickDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: color.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                display,
                style: text.bodyMedium?.copyWith(
                  color: _date == null
                      ? color.onSurfaceVariant
                      : color.onSurface,
                ),
              ),
            ),
            Icon(Icons.edit_calendar, color: color.primary),
          ],
        ),
      ),
    );
  }
}
