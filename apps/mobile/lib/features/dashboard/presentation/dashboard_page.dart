import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const modules = <String>[
    'Body',
    'Nutrition',
    'Hydration',
    'Workout',
    'Sleep',
    'Habits',
    'Lifestyle',
    'Goals',
    'Reports',
    'AI',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUNYA'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Personal Human Operating System',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Your body, habits, data and goals in one place.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) => Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(modules[index],
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
