import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/event_model.dart';
import '../../../services/event_api_service.dart';
import '../../../utils/app_toast.dart';

// 🧩 Widgets con
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
    if (!_formKey.currentState!.validate() || _startDate == null || _startTime == null) {
      // ✅ 2. Sử dụng toast mới
      showAppToast(context, "⚠️ Vui lòng nhập đầy đủ thông tin sự kiện", type: ToastType.warning);
      return;
    }

    final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, _startTime!.hour, _startTime!.minute);
    final end = _endDate != null && _endTime != null
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, _endTime!.hour, _endTime!.minute)
        : start.add(const Duration(hours: 2));

    if (end.isBefore(start.add(const Duration(minutes: 30)))) {
      showAppToast(context, "⏰ Thời gian kết thúc phải sau bắt đầu ít nhất 30 phút", type: ToastType.warning);
      return;
    }

    if (_selectedType == "Sự kiện giới hạn") {
      final guests = int.tryParse(_maxGuestsController.text) ?? 0;
      if (guests < 2) {
        showAppToast(context, "⚠️ Sự kiện giới hạn phải có ít nhất 2 khách mời", type: ToastType.warning);
        return;
      }
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context, created);
        }
      });

    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showAppToast(context, "❌ Lỗi tạo sự kiện: $e", type: ToastType.error);
    }
  }

  // ✅ 3. Xoá toàn bộ code về _showToast, iconForType

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🗓️ Tạo sự kiện mới")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EventFormHeader(title: "Thông tin sự kiện"),
              const SizedBox(height: 16),
              EventTextField(controller: _nameController, label: "Tên sự kiện", icon: Icons.event),
              const SizedBox(height: 16),
              EventTextField(controller: _locationController, label: "Địa điểm tổ chức", icon: Icons.place),
              const SizedBox(height: 16),
              EventDateTimePicker(label: "Thời gian bắt đầu", icon: Icons.calendar_today, onPicked: _onStartPicked),
              const SizedBox(height: 12),
              EventDateTimePicker(label: "Dự kiến kết thúc", icon: Icons.timelapse, onPicked: _onEndPicked),
              const SizedBox(height: 16),
              EventTypeSelector(maxGuestsController: _maxGuestsController, onTypeChanged: (type) { setState(() => _selectedType = type); }),
              const SizedBox(height: 16),
              EventDescriptionField(controller: _descriptionController),
              const SizedBox(height: 20),
              EventMultiImagePicker(onImagesSelected: (files) { setState(() => _selectedImages = files); }),
              const SizedBox(height: 32),
              EventSubmitButton(isLoading: _isSubmitting, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
