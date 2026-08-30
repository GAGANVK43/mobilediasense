import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.changePassword(
        currentPassword: _oldPassCtrl.text,
        newPassword: _newPassCtrl.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              const SizedBox(height: AppSpacing.sm),
            ],
            AppTextField(
              controller: _oldPassCtrl,
              label: 'Current Password',
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _newPassCtrl,
              label: 'New Password',
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 120,
          child: AppButton(
            text: 'Update',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}
