import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/body/presentation/body_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/habits/presentation/habits_page.dart';
import '../../features/hydration/presentation/hydration_page.dart';
import '../../features/nutrition/presentation/nutrition_page.dart';
import '../../features/sleep/presentation/sleep_page.dart';
import '../../features/workout/presentation/workout_page.dart';

final sunyaRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(path: '/dashboard', name: 'dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/body', name: 'body', builder: (context, state) => const BodyPage()),
    GoRoute(path: '/nutrition', name: 'nutrition', builder: (context, state) => const NutritionPage()),
    GoRoute(path: '/hydration', name: 'hydration', builder: (context, state) => const HydrationPage()),
    GoRoute(path: '/workout', name: 'workout', builder: (context, state) => const WorkoutPage()),
    GoRoute(path: '/sleep', name: 'sleep', builder: (context, state) => const SleepPage()),
    GoRoute(path: '/habits', name: 'habits', builder: (context, state) => const HabitsPage()),
    GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const _ComingSoonPage(title: 'Profile')),
    GoRoute(path: '/ai', name: 'ai', builder: (context, state) => const _ComingSoonPage(title: 'SUNYA AI')),
  ],
);

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome_outlined, size: 48),
          const SizedBox(height: 16),
          Text('$title is under active development', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('The foundation is connected; this module will be implemented in the next feature phase.'),
        ]))),
      );
}
