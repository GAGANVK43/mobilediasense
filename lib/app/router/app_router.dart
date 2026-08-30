import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/health_history/presentation/screens/health_history_screen.dart';
import '../../features/assessment/presentation/screens/assessment_wizard_screen.dart';
import '../../features/assessment/presentation/screens/assessment_detail_screen.dart';
import '../../features/assessment/data/models/assessment_model.dart';
import '../../features/prediction/presentation/screens/prediction_result_screen.dart';
import '../../features/prediction/presentation/screens/risk_explanation_screen.dart';
import '../../features/diet/presentation/screens/diet_screen.dart';
import '../../features/chatbot/presentation/screens/chatbot_screen.dart';
import '../../features/food_analysis/presentation/screens/food_analysis_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/disclaimer_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorHealth = GlobalKey<NavigatorState>(debugLabel: 'shellHealth');
final _shellNavigatorAI = GlobalKey<NavigatorState>(debugLabel: 'shellAI');
final _shellNavigatorCare = GlobalKey<NavigatorState>(debugLabel: 'shellCare');
final _shellNavigatorProfile = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Standalone Fullscreen Routes
      GoRoute(
        path: '/assessment/wizard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AssessmentWizardScreen(),
      ),
      GoRoute(
        path: '/assessment/details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final a = state.extra as AssessmentModel;
          return AssessmentDetailScreen(assessment: a);
        },
      ),
      GoRoute(
        path: '/prediction/result',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return PredictionResultScreen(resultData: data);
        },
      ),
      GoRoute(
        path: '/prediction/explanation',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return RiskExplanationScreen(predictionData: data);
        },
      ),
      GoRoute(
        path: '/diet',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DietScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/food-analysis',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FoodAnalysisScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/disclaimer',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DisclaimerScreen(),
      ),

      // Stateful Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Tab 2: Health History & Trends
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHealth,
            routes: [
              GoRoute(
                path: '/health',
                builder: (context, state) => const HealthHistoryScreen(),
              ),
            ],
          ),
          // Tab 3: AI & Nutrition
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAI,
            routes: [
              GoRoute(
                path: '/ai-hub',
                builder: (context, state) => const FoodAnalysisScreen(),
              ),
            ],
          ),
          // Tab 4: Care & Reports
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCare,
            routes: [
              GoRoute(
                path: '/care-reports',
                builder: (context, state) => const ReportsAndCareScreen(),
              ),
            ],
          ),
          // Tab 5: Profile
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
