import 'package:flutter/material.dart';
import 'models/task.dart';
import 'services/task_service.dart';
import 'widgets/add_task_dialog.dart';
import 'widgets/date_selector.dart';
import 'widgets/progress_card.dart';
import 'widgets/task_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskService = TaskService();
  await taskService.init();
  runApp(DailyPlannerApp(taskService: taskService));
}

class DailyPlannerApp extends StatefulWidget {
  final TaskService taskService;

  const DailyPlannerApp({super.key, required this.taskService});

  @override
  State<DailyPlannerApp> createState() => _DailyPlannerAppState();
}

class _DailyPlannerAppState extends State<DailyPlannerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Planner & To-Do',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD0BCFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: DailyPlannerHomeScreen(
        taskService: widget.taskService,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class DailyPlannerHomeScreen extends StatefulWidget {
  final TaskService taskService;
  final VoidCallback onToggleTheme;

  const DailyPlannerHomeScreen({
    super.key,
    required this.taskService,
    required this.onToggleTheme,
  });

  @override
  State<DailyPlannerHomeScreen> createState() => _DailyPlannerHomeScreenState();
}

class _DailyPlannerHomeScreenState extends State<DailyPlannerHomeScreen> {
  DateTime _selectedDate = DateTime.now();
  String _filterCategory = 'All';
  String _filterStatus = 'All'; // 'All', 'Pending', 'Completed'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Work',
    'Personal',
    'Fitness',
    'Study',
    'Shopping',
  ];

  @override
  void initState() {
    super.initState();
    widget.taskService.addListener(_onTaskServiceUpdated);
  }

  @override
  void dispose() {
    widget.taskService.removeListener(_onTaskServiceUpdated);
    _searchController.dispose();
    super.dispose();
  }

  void _onTaskServiceUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Task> _getFilteredTasks() {
    final tasksForDay = widget.taskService.getTasksForDate(_selectedDate);

    return tasksForDay.where((task) {
      // Category filter
      if (_filterCategory != 'All' && task.category != _filterCategory) {
        return false;
      }

      // Status filter
      if (_filterStatus == 'Pending' && task.isCompleted) {
        return false;
      }
      if (_filterStatus == 'Completed' && !task.isCompleted) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch = task.description.toLowerCase().contains(query);
        if (!titleMatch && !descMatch) return false;
      }

      return true;
    }).toList();
  }

  void _openAddTaskSheet([Task? taskToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskBottomSheet(
        selectedDate: _selectedDate,
        taskToEdit: taskToEdit,
        onSave: (task) {
          if (taskToEdit == null) {
            widget.taskService.addTask(task);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task added to daily plan!'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            widget.taskService.updateTask(task);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated successfully!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        onDelete: taskToEdit != null
            ? () => _deleteTaskWithUndo(taskToEdit.id)
            : null,
      ),
    );
  }

  Future<void> _deleteTaskWithUndo(String taskId) async {
    final dailyTasks = widget.taskService.getTasksForDate(_selectedDate);
    final index = dailyTasks.indexWhere((t) => t.id == taskId);

    final deletedTask = await widget.taskService.deleteTask(taskId);
    if (deletedTask != null && mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${deletedTask.title}"'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              widget.taskService.insertTaskAt(
                  index != -1 ? index : 0, deletedTask);
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _confirmDeleteTask(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteTaskWithUndo(task.id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayTasks = widget.taskService.getTasksForDate(_selectedDate);
    final completedCount = dayTasks.where((t) => t.isCompleted).length;
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Planner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Organize your day efficiently',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Date Selector Header
                DateSelector(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Daily Progress Overview Card
                ProgressCard(
                  totalTasks: dayTasks.length,
                  completedTasks: completedCount,
                ),
                const SizedBox(height: 18),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Category Chips Selector
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _filterCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _filterCategory = category;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Status Tabs (All, Pending, Completed)
                Row(
                  children: ['All', 'Pending', 'Completed'].map((status) {
                    final isSelected = _filterStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _filterStatus = status;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Tasks Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tasks (${filteredTasks.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dayTasks.any((t) => t.isCompleted))
                      TextButton.icon(
                        icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                        label: const Text('Clear Completed', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          final completed = dayTasks.where((t) => t.isCompleted).toList();
                          for (var task in completed) {
                            widget.taskService.deleteTask(task.id);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cleared ${completed.length} completed task(s)'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Task Cards List or Empty State
                if (filteredTasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 64,
                          color: theme.colorScheme.outline.withAlpha(100),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dayTasks.isEmpty
                              ? 'No tasks planned for this day'
                              : 'No tasks match your filter',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap + to create a new task',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredTasks.map(
                    (task) => TaskCard(
                      key: ValueKey(task.id),
                      task: task,
                      onToggle: () => widget.taskService.toggleTaskStatus(task.id),
                      onDelete: () => _confirmDeleteTask(task),
                      onEdit: () => _openAddTaskSheet(task),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTaskSheet(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
        elevation: 4,
      ),
    );
  }
}
