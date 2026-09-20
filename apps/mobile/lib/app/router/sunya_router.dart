import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/sunya_app_shell.dart';
import '../../features/body/presentation/body_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/habits/presentation/habits_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/ai/presentation/ai_page.dart';
import '../../features/analytics/presentation/analytics_page.dart';
import '../../features/appearance/presentation/appearance_page.dart';
import '../../features/hydration/presentation/hydration_page.dart';
import '../../features/nutrition/presentation/nutrition_page.dart';
import '../../features/sleep/presentation/sleep_page.dart';
import '../../features/workout/presentation/workout_page.dart';

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
    GoRoute(path: '/ai', name: 'ai', builder: (_, __) => const AiPage()),
    GoRoute(path: '/analytics', name: 'analytics', builder: (_, __) => const AnalyticsPage()),
    GoRoute(path: '/appearance', name: 'appearance', builder: (_, __) => const AppearancePage()),
  ],
);

