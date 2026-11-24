import 'package:flutter/material.dart';
import '../models/task.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Task? taskToEdit;
  final Function(Task) onSave;
  final VoidCallback? onDelete;

  const AddTaskBottomSheet({
    super.key,
    required this.selectedDate,
    this.taskToEdit,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedPriority;
  TimeOfDay? _selectedTime;

  final List<String> _categories = [
    'Personal',
    'Work',
    'Fitness',
    'Study',
    'Shopping',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descController =
        TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedCategory = widget.taskToEdit?.category ?? 'Personal';
    _selectedPriority = widget.taskToEdit?.priority ?? 'Medium';

    if (widget.taskToEdit?.time != null && widget.taskToEdit!.time!.isNotEmpty) {
      _selectedTime = _parseTimeOfDay(widget.taskToEdit!.time!);
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
        hour += 12;
      } else if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.taskToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: widget.taskToEdit?.date ?? widget.selectedDate,
        time: _selectedTime != null ? _formatTimeOfDay(_selectedTime!) : null,
        category: _selectedCategory,
        priority: _selectedPriority,
        isCompleted: widget.taskToEdit?.isCompleted ?? false,
      );

      widget.onSave(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.taskToEdit != null;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Title & Optional Delete Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'Create New Task',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (isEditing && widget.onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          tooltip: 'Delete Task',
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onDelete!();
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Task Title Field
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                decoration: InputDecoration(
                  labelText: 'Task Title *',
                  hintText: 'e.g. Morning team sync or Workout',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Task Description Field
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description / Notes',
                  hintText: 'Add details or subtasks...',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text(
                        _selectedTime == null
                            ? 'Set Time'
                            : _formatTimeOfDay(_selectedTime!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedTime = time;
                          });
                        }
                      },
                    ),
                  ),
                  if (_selectedTime != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      tooltip: 'Clear Time',
                      onPressed: () {
                        setState(() {
                          _selectedTime = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),

              // Category Selector
              Text(
                'Category',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Priority Selector
              Text(
                'Priority',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _priorities.map((pri) {
                  final selected = _selectedPriority == pri;
                  return ChoiceChip(
                    label: Text(pri),
                    selected: selected,
                    selectedColor: pri == 'High'
                        ? Colors.red.withAlpha(50)
                        : (pri == 'Medium'
                            ? Colors.amber.withAlpha(50)
                            : Colors.green.withAlpha(50)),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedPriority = pri;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Add Task to Daily Plan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
