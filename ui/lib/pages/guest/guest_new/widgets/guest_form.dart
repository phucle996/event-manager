import 'package:flutter/material.dart';
import 'package:appflutter/l10n/app_localizations.dart';
import '../../../../models/event_model.dart';

class GuestForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final List<EventModel> events;
  final String? selectedEventId;
  final ValueChanged<String?> onSelectEvent;
  final bool eventsLoading;
  final String? eventsError;
  final VoidCallback onRetryLoadEvents;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const GuestForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.events,
    required this.selectedEventId,
    required this.onSelectEvent,
    required this.eventsLoading,
    required this.eventsError,
    required this.onRetryLoadEvents,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧩 Tiêu đề
          Text(
            l10n.addGuestTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          // 🧾 Họ tên
          TextFormField(
            controller: fullNameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.guestFullNameLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (_) {
              if (fullNameController.text.trim().isEmpty) {
                return l10n.guestNameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 📧 Email
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.guestEmailLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 📱 Số điện thoại
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.guestPhoneLabel,
              border: const OutlineInputBorder(),
            ),
            onFieldSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 16),

          // 📅 Chọn sự kiện
          Text(
            l10n.guestEventLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          _buildEventSelector(context, l10n),
          const SizedBox(height: 24),

          // 💾 Nút lưu
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSubmitting ? null : _handleSubmit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              child: isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    formKey.currentState?.save();
    onSubmit();
  }

  Widget _buildEventSelector(BuildContext context, AppLocalizations l10n) {
    // ⏳ Đang tải
    if (eventsLoading) {
      return const LinearProgressIndicator();
    }

    // ❌ Lỗi khi tải danh sách sự kiện
    if (eventsError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.loadingError(eventsError!),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetryLoadEvents, child: Text(l10n.retry)),
        ],
      );
    }

    // ⚠️ Không có sự kiện
    if (events.isEmpty) {
      return Text(
        l10n.noUpcomingEvents,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    // 🟢 Dropdown chọn sự kiện (đã bỏ logic setState ngầm gây loop)
    return DropdownButtonFormField<String>(
      value: selectedEventId,
      isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: events
          .map(
            (event) => DropdownMenuItem<String>(
              value: event.id,
              child: Text(event.name),
            ),
          )
          .toList(),
      onChanged: onSelectEvent,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.guestEventRequired;
        }
        return null;
      },
    );
  }
}
