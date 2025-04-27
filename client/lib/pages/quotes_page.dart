import 'package:flutter/material.dart';
import 'package:client/Components/task.dart';

class HabitPage extends StatelessWidget {
  const HabitPage({super.key});

  // Temp data for habits
  final List<Map<String, String>> habits = const [
    {
      'id': '1',
      'name': 'Walking',
      'des': 'Walk 5km every morning',
    },
    {
      'id': '2',
      'name': 'Reading',
      'des': 'Read 20 pages of a book',
    },
    {
      'id': '3',
      'name': 'Meditation',
      'des': '10 minutes mindfulness',
    },
    {
      'id': '4',
      'name': 'Hydration',
      'des': 'Drink 8 glasses of water',
    },
    {
      'id': '5',
      'name': 'Exercise',
      'des': 'Complete a 30-minute workout',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Habits"),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: ListView.separated(
          itemCount: habits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final habit = habits[index];
            return TaskWidget(
                  id: habit['id']!,
                  name: habit['name']!,
                  des: habit['des']!,
            );
          },
        ),
      ),
    );
  }
}
