import 'package:flutter/material.dart';
import 'package:appflutter/l10n/app_localizations.dart';

import '../../../models/event_model.dart';
import '../../../models/guest_model.dart';
import '../../../services/event_api_service.dart';
import '../../../utils/app_toast.dart';
import 'widgets/guest_form.dart';

class GuestAddPage extends StatefulWidget {
  final EventModel? event;

  const GuestAddPage({super.key, this.event});

  @override
  State<GuestAddPage> createState() => _GuestAddPageState();
}

class _GuestAddPageState extends State<GuestAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedEventId;
  bool _isSubmitting = false;

  List<EventModel> _events = [];
  bool _eventsLoading = true;
  String? _eventsError;

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.event?.id;

    // 🔹 Load event list sau khi widget được build lần đầu
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 🧩 Tải danh sách sự kiện
  Future<void> _loadEvents() async {
    setState(() {
      _eventsLoading = true;
      _eventsError = null;
    });

    try {
      final events = await EventApiService().getEvents(status: 'Sắp diễn ra');
      if (!mounted) return;

      setState(() {
        _events = events;
        // 🟢 Nếu chưa chọn event thì chọn mặc định event đầu tiên
        _selectedEventId ??= events.isNotEmpty ? events.first.id : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _eventsError = e.toString());
    } finally {
      if (mounted) {
        setState(() => _eventsLoading = false);
      }
    }
  }

  // 💾 Gửi form thêm khách mời
  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty && phone.isEmpty) {
      showAppToast(context, l10n.guestContactRequired, type: ToastType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newGuest = GuestModel(
        id: '',
        fullName: name,
        email: email.isEmpty ? null : email,
        phone: phone.isEmpty ? null : phone,
        eventId: _selectedEventId,
      );

      // 🔹 Giả lập lưu nhanh (API thật thì thay dòng này)
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // ✅ Trả kết quả về GuestPage — KHÔNG show toast tại đây
      if (!mounted) return;
      Navigator.of(context).pop({'guest': newGuest, 'success': true});
    } catch (e) {
      if (!mounted) return;
      showAppToast(
        context,
        l10n.guestCreateError(e.toString()),
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addGuestTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GuestForm(
          formKey: _formKey,
          fullNameController: _nameController,
          emailController: _emailController,
          phoneController: _phoneController,
          events: _events,
          selectedEventId: _selectedEventId,
          onSelectEvent: (value) => setState(() => _selectedEventId = value),
          eventsLoading: _eventsLoading,
          eventsError: _eventsError,
          onRetryLoadEvents: _loadEvents,
          onSubmit: _submit,
          isSubmitting: _isSubmitting,
        ),
      ),
    );
  }
}
