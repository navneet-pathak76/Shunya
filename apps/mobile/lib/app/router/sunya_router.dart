import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/sunya_app_shell.dart';
import '../../features/body/presentation/body_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/habits/presentation/habits_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/ai/presentation/ai_page.dart';
import '../../features/ai/presentation/ai_providers_page.dart';
import '../../features/subscription/presentation/sunya_subscription_page.dart';
import '../../features/ai/presentation/personal_plan_page.dart';
import '../../features/analytics/presentation/analytics_page.dart';
import '../../features/appearance/presentation/appearance_page.dart';
import '../../features/appearance/presentation/appearance_recommendations_page.dart';
import '../../features/hydration/presentation/hydration_page.dart';
import '../../features/nutrition/presentation/nutrition_page.dart';
import '../../features/sleep/presentation/sleep_page.dart';
import '../../features/workout/presentation/workout_page.dart';
import '../../features/reminders/presentation/reminder_settings_page.dart';
import '../../features/health_connect/presentation/health_connect_page.dart';
import '../../features/goals/presentation/goals_page.dart';
import '../../features/wellness/presentation/wellness_page.dart';
import '../../features/export/presentation/data_management_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/subscription/presentation/subscription_page.dart';

final sunyaRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => SunyaAppShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', name: 'dashboard', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/body', name: 'body', builder: (_, __) => const BodyPage()),
        GoRoute(path: '/hydration', name: 'hydration', builder: (_, __) => const HydrationPage()),
        GoRoute(path: '/nutrition', name: 'nutrition', builder: (_, __) => const NutritionPage()),
        GoRoute(path: '/workout', name: 'workout', builder: (_, __) => const WorkoutPage()),
        GoRoute(path: '/sleep', name: 'sleep', builder: (_, __) => const SleepPage()),
        GoRoute(path: '/habits', name: 'habits', builder: (_, __) => const HabitsPage()),
      ],
    ),
    GoRoute(path: '/profile', name: 'profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/settings', name: 'settings', builder: (_, __) => const SettingsPage()),
    GoRoute(path: '/ai', name: 'ai', builder: (_, __) => const AiPage()),
    GoRoute(path: '/subscription', name: 'subscription', builder: (_, __) => const SubscriptionPage()),
    GoRoute(path: '/ai/providers', name: 'aiProviders', builder: (_, __) => const AiProvidersPage()),
    GoRoute(path: '/subscription', name: 'subscription', builder: (_, __) => const SunyaSubscriptionPage()),
    GoRoute(path: '/ai/plan', name: 'aiPlan', builder: (_, __) => const PersonalPlanPage()),
    GoRoute(path: '/health', name: 'health', builder: (_, __) => const HealthConnectPage()),
    GoRoute(path: '/goals', name: 'goals', builder: (_, __) => const GoalsPage()),
    GoRoute(path: '/wellness', name: 'wellness', builder: (_, __) => const WellnessPage()),
    GoRoute(path: '/data', name: 'data', builder: (_, __) => const DataManagementPage()),
    GoRoute(path: '/analytics', name: 'analytics', builder: (_, __) => const AnalyticsPage()),
    GoRoute(path: '/appearance', name: 'appearance', builder: (_, __) => const AppearancePage()),
    GoRoute(path: '/reminders', name: 'reminders', builder: (_, __) => const ReminderSettingsPage()),
    GoRoute(path: '/appearance/recommendations', name: 'appearanceRecommendations', builder: (_, __) => const AppearanceRecommendationsPage()),
  ],
);
