import 'package:appflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../utils/app_toast.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    final appLocalizations = AppLocalizations.of(context)!;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      showAppToast(context, appLocalizations.newPasswordMismatch, type: ToastType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Gọi API đổi mật khẩu của bạn tại đây
      await Future.delayed(const Duration(seconds: 1)); // Giả lập gọi API

      if (!mounted) return;
      showAppToast(context, appLocalizations.changePasswordSuccess, type: ToastType.success);
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      showAppToast(context, '${appLocalizations.error}: $e', type: ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.changePassword)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: appLocalizations.oldPassword),
                validator: (v) => v!.isEmpty ? appLocalizations.pleaseEnterOldPassword : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: appLocalizations.newPassword),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return appLocalizations.passwordTooShort;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: appLocalizations.confirmNewPassword),
                validator: (v) => v!.isEmpty ? appLocalizations.pleaseConfirmPassword : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : Text(appLocalizations.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
