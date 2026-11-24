import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Personal':
        return Colors.purple;
      case 'Fitness':
        return Colors.orange;
      case 'Study':
        return Colors.green;
      case 'Shopping':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work_outline;
      case 'Personal':
        return Icons.person_outline;
      case 'Fitness':
        return Icons.fitness_center_outlined;
      case 'Study':
        return Icons.menu_book_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.task_alt;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.amber.shade800;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(task.category);
    final priorityColor = _getPriorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? theme.colorScheme.surfaceContainerHighest.withAlpha(80)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? Colors.transparent
              : theme.colorScheme.outlineVariant.withAlpha(120),
        ),
        boxShadow: task.isCompleted
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Custom Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),

                // Task Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? theme.colorScheme.onSurface.withAlpha(120)
                              : theme.colorScheme.onSurface,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: task.isCompleted
                                ? theme.colorScheme.onSurfaceVariant.withAlpha(100)
                                : theme.colorScheme.onSurfaceVariant,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Tags Row (Category, Time, Priority)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Category Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: categoryColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(task.category),
                                  size: 12,
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: categoryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Time Tag
                          if (task.time != null && task.time!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer
                                    .withAlpha(150),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: theme.colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.time!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          theme.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Priority Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: priorityColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: priorityColor.withAlpha(80),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              task.priority,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete Button (explicitly included & highlighted)
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: Colors.redAccent,
                  tooltip: 'Delete task',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
