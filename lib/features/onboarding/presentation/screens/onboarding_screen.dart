import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'AI-Powered Risk Assessment',
      'description': 'Predict potential diabetes risk in seconds with our clinically-trained Random Forest ML engine.',
      'icon': Icons.insights_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Intelligent Nutrition & Vision',
      'description': 'Analyze meal glycemic indices and macronutrients instantly via camera scanning and text queries.',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFF0284C7),
    },
    {
      'title': 'DiaSense AI Assistant',
      'description': 'Ask questions anytime to get real-time health, dietary, and lifestyle guidance tailored for you.',
      'icon': Icons.smart_toy_rounded,
      'color': AppColors.secondary,
    },
  ];

  Future<void> _completeOnboarding() async {
    final storage = ref.read(secureStorageProvider);
    await storage.setHasSeenOnboarding(true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              // Top Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xxl - 12),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 72,
                            color: item['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          item['description'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondaryLight,
                                height: 1.5,
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? AppColors.primary : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Bottom Action Button
              AppButton(
                text: _currentIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentIndex < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
