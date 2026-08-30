import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/health_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../providers/nearby_care_provider.dart';

class NearbyCareScreen extends ConsumerStatefulWidget {
  const NearbyCareScreen({super.key});

  @override
  ConsumerState<NearbyCareScreen> createState() => _NearbyCareScreenState();
}

class _NearbyCareScreenState extends ConsumerState<NearbyCareScreen> {
  final _searchCtrl = TextEditingController(text: 'Bengaluru');

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final careState = ref.watch(nearbyCareProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Location Search Field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'City, Area, or PIN (e.g. Mumbai, Indiranagar)',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                onSubmitted: (val) {
                  ref.read(nearbyCareProvider.notifier).searchCare(query: val);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                ref.read(nearbyCareProvider.notifier).searchCare(query: _searchCtrl.text);
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Type Filter Chips
        Row(
          children: [
            ChoiceChip(
              label: const Text('Hospitals & Clinics'),
              selected: careState.activeType == 'hospital',
              onSelected: (val) {
                if (val) ref.read(nearbyCareProvider.notifier).searchCare(type: 'hospital');
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              label: const Text('Diagnostic Labs'),
              selected: careState.activeType == 'laboratory',
              onSelected: (val) {
                if (val) ref.read(nearbyCareProvider.notifier).searchCare(type: 'laboratory');
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Facilities List
        if (careState.isLoading) ...[
          const SkeletonLoader(width: double.infinity, height: 90),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonLoader(width: double.infinity, height: 90),
        ] else if (careState.error != null) ...[
          ErrorStateView(
            message: careState.error!,
            onRetry: () => ref.read(nearbyCareProvider.notifier).searchCare(),
          ),
        ] else if (careState.facilities.isEmpty) ...[
          const EmptyStateView(
            title: 'No Facilities Found',
            description: 'Try searching for a different city or neighborhood location.',
          ),
        ] else ...[
          ...careState.facilities.map((fac) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HealthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fac.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            ' km',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fac.address ?? 'Medical Road',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                    if (fac.phone != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(fac.phone!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
