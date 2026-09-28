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
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
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

              // Mode 1: GPS Option
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(nearbyCareProvider.notifier).useCurrentLocation();
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
                            Text('Use My Current Location (GPS)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.primaryDark)),
                            Text('Automatically detect nearby clinics using satellite GPS', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mode 2: Manual Search Field
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter city, area, or PIN code (e.g. 560049)',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                    onPressed: () {
                      final val = _searchCtrl.text.trim();
                      if (val.isNotEmpty) {
                        Navigator.pop(ctx);
                        ref.read(nearbyCareProvider.notifier).searchManualLocation(val);
                      }
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    Navigator.pop(ctx);
                    ref.read(nearbyCareProvider.notifier).searchManualLocation(val.trim());
                  }
                },
              ),
              const SizedBox(height: 16),

              // Popular Cities Quick Chips
              const Text('Popular Cities', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Bengaluru',
                  'Whitefield',
                  'Indiranagar',
                  'Koramangala',
                  '560049',
                  'Mysuru',
                  'Mumbai',
                  'New Delhi',
                  'Hyderabad',
                  'Chennai',
                  'Pune',
                ].map((loc) {
                  return ActionChip(
                    avatar: const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                    label: Text(loc, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.grey.shade100,
                    onPressed: () {
                      _searchCtrl.text = loc;
                      Navigator.pop(ctx);
                      ref.read(nearbyCareProvider.notifier).searchManualLocation(loc);
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
    final isGps = careState.locationMode == LocationMode.currentGps;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // 1. Dual Mode Top Quick Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: careState.isLoading
                    ? null
                    : () => ref.read(nearbyCareProvider.notifier).useCurrentLocation(),
                icon: const Icon(Icons.my_location_rounded, size: 16),
                label: const Text('📍 My Location', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGps ? AppColors.primary : AppColors.surfaceLight,
                  foregroundColor: isGps ? Colors.white : AppColors.textPrimaryLight,
                  elevation: isGps ? 1 : 0,
                  side: BorderSide(color: isGps ? AppColors.primary : AppColors.borderLight),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showLocationPickerSheet(context, careState),
                icon: const Icon(Icons.search_rounded, size: 16, color: AppColors.primary),
                label: const Text('🔎 Search Area', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // 2. Selected Location Card with Change Action
        InkWell(
          onTap: () => _showLocationPickerSheet(context, careState),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isGps ? AppColors.primarySurface : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: isGps ? AppColors.primary.withOpacity(0.5) : AppColors.borderLight),
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
                      Text(
                        isGps ? '📍 Current Location' : '📍 Selected Location',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight),
                      ),
                      Text(
                        careState.displayName,
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

        // 3. Location Permission Banners if Needed
        if (careState.locationState == LocationState.permissionDenied) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.riskModerateBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.riskModerate),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Location permission is required to detect GPS automatically.',
                    style: TextStyle(fontSize: 11, color: AppColors.riskModerate, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(nearbyCareProvider.notifier).useCurrentLocation(),
                  child: const Text('Allow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        if (careState.locationState == LocationState.permissionDeniedForever || careState.locationState == LocationState.serviceDisabled) ...[
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
                Expanded(
                  child: Text(
                    careState.locationState == LocationState.serviceDisabled
                        ? 'Device GPS is turned off.'
                        : 'GPS permission disabled in settings.',
                    style: const TextStyle(fontSize: 11, color: AppColors.riskModerate, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  child: const Text('Settings', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // 4. Quick Location Search Input Field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Enter city, area or PIN code (e.g. 560049)',
                  hintStyle: const TextStyle(fontSize: 12.5),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _searchCtrl.clear()),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    ref.read(nearbyCareProvider.notifier).searchManualLocation(val.trim());
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
                  ref.read(nearbyCareProvider.notifier).searchManualLocation(query);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // 5. Category Selection Chips (Hospitals & Clinics vs Diagnostic Labs)
        Row(
          children: [
            ChoiceChip(
              label: const Text('🏥 Hospitals & Clinics'),
              selected: careState.activeType == 'hospital',
              onSelected: (val) {
                if (val) ref.read(nearbyCareProvider.notifier).changeCategory('hospital');
              },
            ),
            const SizedBox(width: AppSpacing.xs),
            ChoiceChip(
              label: const Text('🔬 Diagnostic Labs'),
              selected: careState.activeType == 'laboratory',
              onSelected: (val) {
                if (val) ref.read(nearbyCareProvider.notifier).changeCategory('laboratory');
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // 6. Radius & Sorting Row
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
                      onTap: () => ref.read(nearbyCareProvider.notifier).changeRadius(r),
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

        // 7. Facilities List / Loading / Empty / Error State
        if (careState.isLoading) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Finding healthcare facilities nearby...',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const SkeletonLoader(width: double.infinity, height: 90),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonLoader(width: double.infinity, height: 90),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonLoader(width: double.infinity, height: 90),
        ] else if (careState.error != null) ...[
          ErrorStateView(
            message: careState.error!,
            onRetry: () => ref.read(nearbyCareProvider.notifier).useCurrentLocation(),
          ),
        ] else if (careState.facilities.isEmpty) ...[
          EmptyStateView(
            title: 'No ${careState.activeType == "hospital" ? "Hospitals or Clinics" : "Diagnostic Labs"} Found within ${careState.radiusMeters ~/ 1000} km',
            description: 'Try expanding your search radius or search for a nearby city area or PIN code.',
            actionText: careState.radiusMeters < 25000 ? 'Search within 25 km' : 'Search City Manually',
            onAction: () {
              if (careState.radiusMeters < 25000) {
                ref.read(nearbyCareProvider.notifier).changeRadius(25000);
              } else {
                _showLocationPickerSheet(context, careState);
              }
            },
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

                    // Actions: Get Directions and Call Facility
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

