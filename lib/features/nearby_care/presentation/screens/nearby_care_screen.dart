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

  void _showLocationPickerSheet(BuildContext context, NearbyCareState careState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Your Location', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),

              // GPS Option (Swiggy / Zomato style)
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(nearbyCareProvider.notifier).searchByCurrentGps();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Use Current Location (GPS)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.primaryDark)),
                            Text('Detect using device satellite GPS coordinates', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Manual Search Field
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search city or area (e.g. Indiranagar, Whitefield)',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                    onPressed: () {
                      final val = _searchCtrl.text.trim();
                      if (val.isNotEmpty) {
                        Navigator.pop(ctx);
                        ref.read(nearbyCareProvider.notifier).searchCare(query: val, isManual: true);
                      }
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    Navigator.pop(ctx);
                    ref.read(nearbyCareProvider.notifier).searchCare(query: val.trim(), isManual: true);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Popular Cities (Swiggy / Zomato style)
              const Text('Popular Cities', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Bengaluru',
                  'Mumbai',
                  'New Delhi',
                  'Hyderabad',
                  'Chennai',
                  'Mysuru',
                  'Pune',
                  'Kolkata',
                ].map((city) {
                  return ActionChip(
                    avatar: const Icon(Icons.location_city_rounded, size: 14, color: AppColors.primary),
                    label: Text(city, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.grey.shade100,
                    onPressed: () {
                      _searchCtrl.text = city;
                      Navigator.pop(ctx);
                      ref.read(nearbyCareProvider.notifier).searchCare(query: city, isManual: true);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final careState = ref.watch(nearbyCareProvider);
    final isGps = careState.locationState == LocationState.gpsSuccess;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // 1. Swiggy / Zomato Style Top Location Header
        InkWell(
          onTap: () => _showLocationPickerSheet(context, careState),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isGps ? AppColors.primarySurface : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: isGps ? AppColors.primary : AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isGps ? Icons.my_location_rounded : Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isGps ? 'GPS Location' : 'Selected Location',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondaryLight),
                        ],
                      ),
                      Text(
                        careState.searchQuery,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showLocationPickerSheet(context, careState),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
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

