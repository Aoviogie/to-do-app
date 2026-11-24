class Task {
  final String id;
  String title;
  String description;
  DateTime date;
  String? time;
  String category;
  String priority; // 'Low', 'Medium', 'High'
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.time,
    this.category = 'Personal',
    this.priority = 'Medium',
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String?,
      category: (map['category'] as String?) ?? 'Personal',
      priority: (map['priority'] as String?) ?? 'Medium',
      isCompleted: (map['isCompleted'] as bool?) ?? false,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? category,
    String? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
