import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;

  const ProgressCard({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double progress = totalTasks == 0 ? 0 : completedTasks / totalTasks;
    final int percentage = (progress * 100).round();

    String getMotivationalMsg() {
      if (totalTasks == 0) return 'No tasks planned for today!';
      if (progress == 1.0) return 'All done! Fantastic job! 🎉';
      if (progress >= 0.7) return 'Almost there! Keep going! 💪';
      if (progress >= 0.3) return 'Making great progress! 🚀';
      return 'Let\'s get things done today! 🎯';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(75),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedTasks / $totalTasks Tasks',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            getMotivationalMsg(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
