import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/disclaimer_card.dart';
import '../../../../core/widgets/health_card.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import 'change_password_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).loadProfileStats());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final dashboardAsync = ref.watch(dashboardDataProvider);

    final fullName = user?.fullName ?? 'DiaSense User';
    final email = user?.email ?? 'user@diasense.com';
    final ageStr = user?.age != null ? user!.age.toString() : '35';
    final genderStr = user?.gender ?? 'Male';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // 1. User Header Card
            HealthCard(
              backgroundColor: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            'Age: ' + ageStr + ' yrs • Gender: ' + genderStr,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Screening Summary Stats
            Text('Health & Screening Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            dashboardAsync.maybeWhen(
              data: (d) {
                final totalAssessments = d.assessmentHistory.length;
                final risk = d.riskLevel;
                final bmi = d.healthSummary.latestBmi != null
                    ? d.healthSummary.latestBmi!.toStringAsFixed(1)
                    : '24.2';

                return Row(
                  children: [
                    _buildStatCard('Assessments', totalAssessments.toString(), AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatCard('Risk Level', risk, AppColors.riskModerate),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatCard('BMI', bmi, const Color(0xFF10B981)),
                  ],
                );
              },
              orElse: () => Row(
                children: [
                  _buildStatCard('Assessments', '1', AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  _buildStatCard('Risk Level', 'Optimal', AppColors.riskLow),
                  const SizedBox(width: AppSpacing.sm),
                  _buildStatCard('BMI', '24.2', const Color(0xFF10B981)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. Account & Security Settings
            Text('Account & Security', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            HealthCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: AppColors.primary),
                    title: const Text('Edit Profile'),
                    subtitle: const Text('Update full name, age, and gender', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => context.push('/profile/edit'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                    title: const Text('Change Password'),
                    subtitle: const Text('Manage your account security credentials', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const ChangePasswordDialog(),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
                    title: const Text('Medical & AI Disclaimer'),
                    subtitle: const Text('Clinical compliance and usage guidelines', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => context.push('/profile/disclaimer'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4. Logout Button
            AppButton(
              text: 'Sign Out of Account',
              icon: Icons.logout_rounded,
              isOutlined: true,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Sign Out'),
                    content: const Text('Are you sure you want to sign out of DiaSense?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskHigh),
                        child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }
}
