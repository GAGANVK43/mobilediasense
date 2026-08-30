import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  String _gender = 'Other';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _ageCtrl = TextEditingController(text: user?.age?.toString() ?? '');
    _gender = user?.gender ?? 'Other';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final age = int.tryParse(_ageCtrl.text.trim());
      await repo.updateProfile(fullName: _nameCtrl.text.trim(), age: age, gender: _gender);
      await ref.read(authProvider.notifier).loadProfileStats();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              controller: _nameCtrl,
              label: 'Full Name',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _ageCtrl,
              label: 'Age',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Gender', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Container(
              height: AppSpacing.inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _gender,
                  isExpanded: true,
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _gender = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: 'Save Changes',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
