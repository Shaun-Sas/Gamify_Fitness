import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Progressbar extends StatelessWidget {
  final int points;

  const Progressbar({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    int currentLevel = (points / 100).floor();
    double progressPercent = (points % 100) / 100;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Level $currentLevel'),
        LinearPercentIndicator(
          lineHeight: 6,
          width: MediaQuery.of(context).size.width - 220,
          percent: progressPercent,
          backgroundColor: Colors.grey.shade400,
          progressColor: Colors.green,
        ),
        Text(
          'Progress: ${(progressPercent * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
