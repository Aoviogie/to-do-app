import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Generate dates for -3 days to +3 days around selectedDate or current week
    final today = DateTime.now();
    final dates = List.generate(7, (index) {
      return today.add(Duration(days: index - 3));
    });

    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '${monthNames[selectedDate.month - 1]} ${selectedDate.year}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.date_range_outlined),
              tooltip: 'Pick Date',
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  onDateSelected(picked);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 75,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isToday
                            ? theme.colorScheme.primaryContainer.withAlpha(128)
                            : theme.colorScheme.surfaceContainerHighest.withAlpha(100)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isToday
                              ? theme.colorScheme.primary.withAlpha(128)
                              : Colors.transparent),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekDays[date.weekday % 7],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
