import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/event_model.dart';
import '../../../services/event_api_service.dart';
import '../../../utils/app_toast.dart';
import './widgets/header.dart';
import './widgets/text_field.dart';
import './widgets/datetime_picker.dart';
import './widgets/type_selector.dart';
import './widgets/description_field.dart';
import './widgets/image_picker.dart';
import './widgets/submit_button.dart';

class EventCreatePage extends StatefulWidget {
  const EventCreatePage({super.key});

  @override
  State<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends State<EventCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _api = EventApiService();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxGuestsController = TextEditingController();

  String _selectedType = "Sự kiện mở";
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  List<File> _selectedImages = [];
  bool _isSubmitting = false;

  void _onStartPicked(DateTime date, TimeOfDay time) {
    setState(() {
      _startDate = date;
      _startTime = time;
    });
  }

  void _onEndPicked(DateTime date, TimeOfDay time) {
    setState(() {
      _endDate = date;
      _endTime = time;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _startTime == null) {
      showAppToast(context, "⚠️ Vui lòng nhập đầy đủ thông tin", type: ToastType.warning);
      return;
    }

    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final end = _endDate != null && _endTime != null
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day,
        _endTime!.hour, _endTime!.minute)
        : start.add(const Duration(hours: 2));

    if (end.isBefore(start.add(const Duration(minutes: 30)))) {
      showAppToast(context, "⏰ Thời gian kết thúc phải sau bắt đầu ít nhất 30 phút",
          type: ToastType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final event = EventModel(
        id: "",
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        status: "Sắp diễn ra",
        startDate: start,
        endDate: end,
        description: _descriptionController.text.trim(),
        maxGuests: int.tryParse(_maxGuestsController.text) ?? 0,
        type: _selectedType,
      );

      final created = await _api.createEventWithImages(event, _selectedImages);
      if (!mounted) return;
      Navigator.pop(context, created);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showAppToast(context, "❌ Lỗi tạo sự kiện: $e", type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: color.background,
      appBar: AppBar(
        backgroundColor: color.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "🗓️ Tạo sự kiện mới",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Hero Header Gradient Section
              Container(
                padding: const EdgeInsets.all(22),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF32B768), Color(0xFF4ADE80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: color.primary.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_box_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Hãy tạo sự kiện của bạn một cách chuyên nghiệp 🎉",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Card 1: Thông tin cơ bản
              _buildFormCard(
                context,
                title: "Thông tin cơ bản",
                children: [
                  EventTextField(
                    controller: _nameController,
                    label: "Tên sự kiện",
                    icon: Icons.event_rounded,
                  ),
                  const SizedBox(height: 14),
                  EventTextField(
                    controller: _locationController,
                    label: "Địa điểm tổ chức",
                    icon: Icons.place_rounded,
                  ),
                  const SizedBox(height: 14),
                  EventDateTimePicker(
                    label: "Thời gian bắt đầu",
                    icon: Icons.calendar_month_rounded,
                    onPicked: _onStartPicked,
                  ),
                  const SizedBox(height: 14),
                  EventDateTimePicker(
                    label: "Dự kiến kết thúc",
                    icon: Icons.timelapse_rounded,
                    onPicked: _onEndPicked,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 Card 2: Chi tiết & mô tả
              _buildFormCard(
                context,
                title: "Chi tiết & mô tả",
                children: [
                  EventTypeSelector(
                    maxGuestsController: _maxGuestsController,
                    onTypeChanged: (type) => setState(() => _selectedType = type),
                  ),
                  const SizedBox(height: 18),
                  EventDescriptionField(controller: _descriptionController),
                  const SizedBox(height: 20),
                  EventMultiImagePicker(
                    onImagesSelected: (files) {
                      setState(() => _selectedImages = files);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // 🔹 Gradient Submit Button
              GestureDetector(
                onTap: _isSubmitting ? null : _submit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isSubmitting
                          ? [Colors.grey, Colors.grey.shade400]
                          : [const Color(0xFF32B768), const Color(0xFF4ADE80)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF32B768).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Tạo sự kiện",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🧩 Helper - build form section card
  Widget _buildFormCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
