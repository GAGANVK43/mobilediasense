import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchUrlHelper(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final careState = ref.watch(nearbyCareProvider);
    final isGps = careState.locationState == LocationState.gpsSuccess;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // 1. GPS Auto-detect Button Banner
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isGps ? AppColors.primarySurface : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: isGps ? AppColors.primary : AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(
                isGps ? Icons.my_location_rounded : Icons.location_searching_rounded,
                color: isGps ? AppColors.primary : AppColors.textSecondaryLight,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGps ? 'Using Current Device GPS' : 'Search by Current GPS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isGps ? AppColors.primaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      isGps ? 'Precise coordinates active' : 'Find hospitals closest to your exact position',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: careState.isLoading
                    ? null
                    : () => ref.read(nearbyCareProvider.notifier).searchByCurrentGps(),
                icon: const Icon(Icons.gps_fixed, size: 16),
                label: const Text('Locate Me', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // 2. Permission Denied / Settings Banner if needed
        if (careState.locationState == LocationState.permissionDeniedForever) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.riskModerateBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.riskModerate),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'GPS permission disabled in settings.',
                    style: TextStyle(fontSize: 11, color: AppColors.riskModerate, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  child: const Text('Open Settings', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // 3. Location Search Field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search city/area (e.g. Bengaluru, Mumbai, Indiranagar)',
                  hintStyle: const TextStyle(fontSize: 12.5),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    ref.read(nearbyCareProvider.notifier).searchCare(query: val.trim(), isManual: true);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                final query = _searchCtrl.text.trim();
                if (query.isNotEmpty) {
                  ref.read(nearbyCareProvider.notifier).searchCare(query: query, isManual: true);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // 4. Type Filter Chips & Radius / Sort Row
        Row(
          children: [
            ChoiceChip(
              label: const Text('🏥 Hospitals & Clinics'),
              selected: careState.activeType == 'hospital',
              onSelected: (val) {
                if (val) ref.read(nearbyCareProvider.notifier).searchCare(type: 'hospital');
              },
            ),
            const SizedBox(width: AppSpacing.xs),
            ChoiceChip(
              label: const Text('🔬 Diagnostic Labs'),
              selected: careState.activeType == 'laboratory',
              onSelected: (val) {
                if (val) ref.read(nearbyCareProvider.notifier).searchCare(type: 'laboratory');
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Radius Filters & Sort Dropdown Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Radius: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
                ...[5000, 10000, 25000].map((r) {
                  final label = '${r ~/ 1000}km';
                  final isSelected = careState.radiusMeters == r;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      onTap: () => ref.read(nearbyCareProvider.notifier).searchCare(radius: r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            // Sort Dropdown
            DropdownButton<String>(
              value: careState.sortBy,
              underline: const SizedBox(),
              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700),
              icon: const Icon(Icons.sort, size: 16, color: AppColors.primary),
              items: const [
                DropdownMenuItem(value: 'distance', child: Text('Nearest')),
                DropdownMenuItem(value: 'name', child: Text('Name')),
                DropdownMenuItem(value: 'rating', child: Text('Top Rated')),
              ],
              onChanged: (val) {
                if (val != null) ref.read(nearbyCareProvider.notifier).setSortBy(val);
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // 5. Facilities List
        if (careState.isLoading) ...[
          const SkeletonLoader(width: double.infinity, height: 90),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonLoader(width: double.infinity, height: 90),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonLoader(width: double.infinity, height: 90),
        ] else if (careState.error != null) ...[
          ErrorStateView(
            message: careState.error!,
            onRetry: () => ref.read(nearbyCareProvider.notifier).searchCare(),
          ),
        ] else if (careState.facilities.isEmpty) ...[
          EmptyStateView(
            title: 'No Nearby Facilities Found',
            description: 'Try expanding your search radius to 10km or 25km, or search for a nearby city area.',
            actionText: 'Expand Radius (25 km)',
            onAction: () => ref.read(nearbyCareProvider.notifier).searchCare(radius: 25000),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${careState.facilities.length} verified facilities nearby',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight),
                ),
                Text(
                  'Within ${careState.radiusMeters ~/ 1000} km',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                ),
              ],
            ),
          ),
          ...careState.facilities.map((fac) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HealthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            fac.name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            '${fac.distance.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fac.address,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            fac.type.toUpperCase(),
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight),
                          ),
                        ),
                        if (fac.openNow != null) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                fac.openNow! ? Icons.check_circle : Icons.schedule,
                                size: 12,
                                color: fac.openNow! ? Colors.green : Colors.amber.shade800,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                fac.openNow! ? 'Open 24/7' : 'Open',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: fac.openNow! ? Colors.green : Colors.amber.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 6),

                    // Actions: Get Directions and Call
                    Row(
                      children: [
                        if (fac.mapsUrl != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _launchUrlHelper(fac.mapsUrl!),
                              icon: const Icon(Icons.directions_outlined, size: 16, color: AppColors.primary),
                              label: const Text('Directions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                              ),
                            ),
                          ),
                        if (fac.mapsUrl != null && fac.phone != null) const SizedBox(width: AppSpacing.sm),
                        if (fac.phone != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _launchUrlHelper('tel:${fac.phone!}'),
                              icon: const Icon(Icons.call_outlined, size: 16, color: Colors.white),
                              label: const Text('Call Facility', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                              ),
                            ),
                          ),
                      ],
                    ),
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

