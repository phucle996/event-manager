import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../models/event_model.dart';
import '../../../services/event_api_service.dart';
import '../../../../utils/app_toast.dart';

import '../create/widgets/header.dart';
import '../create/widgets/text_field.dart';
import '../create/widgets/datetime_picker.dart';
import '../create/widgets/type_selector.dart';
import '../create/widgets/description_field.dart';
import '../create/widgets/submit_button.dart';

class EventEditPage extends StatefulWidget {
  final EventModel event;

  const EventEditPage({super.key, required this.event});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = EventApiService();

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxGuestsController;

  late String _selectedType;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late List<String> _imageUrls;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _nameController = TextEditingController(text: e.name);
    _locationController = TextEditingController(text: e.location);
    _descriptionController = TextEditingController(text: e.description ?? '');
    _maxGuestsController =
        TextEditingController(text: e.maxGuests?.toString() ?? '0');
    _selectedType = e.type;
    _startDate = e.startDate;
    _startTime = TimeOfDay.fromDateTime(e.startDate);
    _endDate = e.endDate;
    _endTime = TimeOfDay.fromDateTime(e.endDate);
    _imageUrls = List.from(e.imageUrls);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      showAppToast(context, l10n.checkInfo, type: ToastType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updatedEvent = EventModel(
        id: widget.event.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        status: widget.event.status,
        startDate: DateTime(_startDate.year, _startDate.month, _startDate.day,
            _startTime.hour, _startTime.minute),
        endDate: DateTime(_endDate.year, _endDate.month, _endDate.day,
            _endTime.hour, _endTime.minute),
        description: _descriptionController.text.trim(),
        maxGuests: int.tryParse(_maxGuestsController.text) ?? 0,
        type: _selectedType,
        imageUrls: _imageUrls,
      );

      final result = await _api.updateEvent(updatedEvent);

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppToast(context, l10n.updateSuccess,
              type: ToastType.success);
          Navigator.pop(context, result);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showAppToast(context, l10n.updateError(e.toString()),
          type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editEvent)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventFormHeader(title: l10n.eventInfo),
              const SizedBox(height: 16),
              EventTextField(
                  controller: _nameController,
                  label: l10n.eventName,
                  icon: Icons.event),
              const SizedBox(height: 16),
              EventTextField(
                  controller: _locationController,
                  label: l10n.eventLocation,
                  icon: Icons.place),
              const SizedBox(height: 16),
              Text(
                  "${l10n.start}: ${DateFormat('dd/MM/yyyy HH:mm').format(_startDate)}"),
              EventDateTimePicker(
                  label: l10n.changeStartTime,
                  icon: Icons.calendar_today,
                  onPicked: (d, t) =>
                      setState(() {
                        _startDate = d;
                        _startTime = t;
                      })),
              const SizedBox(height: 12),
              Text(
                  "${l10n.end}: ${DateFormat('dd/MM/yyyy HH:mm').format(_endDate)}"),
              EventDateTimePicker(
                  label: l10n.changeEndTime,
                  icon: Icons.timelapse,
                  onPicked: (d, t) =>
                      setState(() {
                        _endDate = d;
                        _endTime = t;
                      })),
              const SizedBox(height: 16),
              EventTypeSelector(
                  maxGuestsController: _maxGuestsController,
                  onTypeChanged: (type) => setState(() => _selectedType = type)),
              const SizedBox(height: 16),
              EventDescriptionField(controller: _descriptionController),
              const SizedBox(height: 20),
              EventFormHeader(title: l10n.currentImages),
              _buildImageGrid(),
              const SizedBox(height: 32),
              EventSubmitButton(
                isLoading: _isSubmitting,
                onPressed: _submit,
                label: l10n.updateEvent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    final l10n = AppLocalizations.of(context)!;
    if (_imageUrls.isEmpty) {
      return Text(l10n.noImages,
          style: const TextStyle(fontStyle: FontStyle.italic));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(_imageUrls[index], fit: BoxFit.cover),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _imageUrls.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}