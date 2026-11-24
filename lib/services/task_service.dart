import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskService extends ChangeNotifier {
  static const String _boxName = 'tasks_box';
  Box<Map>? _box;
  final List<Task> _tasks = [];
  bool _isInitialized = false;

  List<Task> get allTasks => List.unmodifiable(_tasks);

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<Map>(_boxName);
      _loadTasksFromHive();
    } catch (e) {
      debugPrint('Hive init failed, using in-memory mode: $e');
      _loadDummyData();
    }
    _isInitialized = true;
    notifyListeners();
  }

  void _loadTasksFromHive() {
    _tasks.clear();
    if (_box != null && _box!.isNotEmpty) {
      for (var key in _box!.keys) {
        final map = _box!.get(key);
        if (map != null) {
          try {
            _tasks.add(Task.fromMap(map));
          } catch (e) {
            debugPrint('Error parsing task: $e');
          }
        }
      }
    } else {
      _loadDummyData();
      _saveAllToHive();
    }
  }

  void _loadDummyData() {
    final now = DateTime.now();
    _tasks.addAll([
      Task(
        id: '1',
        title: 'Morning Team Sync',
        description: 'Discuss sprint goals and project updates with team',
        date: now,
        time: '09:00 AM',
        category: 'Work',
        priority: 'High',
        isCompleted: true,
      ),
      Task(
        id: '2',
        title: 'Gym & Cardio Workout',
        description: '30 mins treadmill + weight training',
        date: now,
        time: '07:30 AM',
        category: 'Fitness',
        priority: 'Medium',
        isCompleted: true,
      ),
      Task(
        id: '3',
        title: 'Review Pull Requests',
        description: 'Check codebase changes and leave feedback',
        date: now,
        time: '11:30 AM',
        category: 'Work',
        priority: 'High',
        isCompleted: false,
      ),
      Task(
        id: '4',
        title: 'Buy Groceries & Supplies',
        description: 'Milk, vegetables, fruits, and snacks',
        date: now,
        time: '04:00 PM',
        category: 'Shopping',
        priority: 'Low',
        isCompleted: false,
      ),
      Task(
        id: '5',
        title: 'Read Flutter Documentation',
        description: 'Learn latest features and performance tips',
        date: now,
        time: '08:00 PM',
        category: 'Study',
        priority: 'Medium',
        isCompleted: false,
      ),
    ]);
  }

  void _saveAllToHive() {
    if (_box == null) return;
    _box!.clear();
    for (var task in _tasks) {
      _box!.put(task.id, task.toMap());
    }
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    if (_box != null) {
      await _box!.put(task.id, task.toMap());
    }
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      if (_box != null) {
        await _box!.put(updatedTask.id, updatedTask.toMap());
      }
      notifyListeners();
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final updated = task.copyWith(isCompleted: !task.isCompleted);
      _tasks[index] = updated;
      if (_box != null) {
        await _box!.put(updated.id, updated.toMap());
      }
      notifyListeners();
    }
  }

  Future<Task?> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final removedTask = _tasks.removeAt(index);
      if (_box != null) {
        await _box!.delete(id);
      }
      notifyListeners();
      return removedTask;
    }
    return null;
  }

  Future<void> insertTaskAt(int index, Task task) async {
    _tasks.insert(index, task);
    if (_box != null) {
      await _box!.put(task.id, task.toMap());
    }
    notifyListeners();
  }
}
