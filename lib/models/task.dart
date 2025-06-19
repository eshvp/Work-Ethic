
class Task {
  final String id;
  final String title;
  String description;
  bool isCompleted;
  List<Map<String, DateTime>> timeEntries;
  double estimatedHours;
  bool estimateInfoShown;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.estimatedHours = 0.0,
    this.estimateInfoShown = false,
    List<Map<String, DateTime>>? timeEntries,
  }) : timeEntries = timeEntries ?? [];

  Duration getTotalTimeSpent() {
    if (timeEntries.isEmpty) {
      return Duration.zero;
    }
    
    Duration total = Duration.zero;
    for (var entry in timeEntries) {
      if (entry.containsKey('start') && entry.containsKey('end')) {
        total += entry['end']!.difference(entry['start']!);
      }
    }
    return total;
  }
  
  double getProgressPercentage() {
    if (isCompleted) return 1.0;
    if (estimatedHours <= 0) return 0.1;
    
    final hoursSpent = getTotalTimeSpent().inMinutes / 60.0;
    final progress = hoursSpent / estimatedHours;
    
    if (progress >= 0.99 && !isCompleted) return 0.99;
    return progress.clamp(0.0, 1.0);
  }
  
  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'estimatedHours': estimatedHours,
      'estimateInfoShown': estimateInfoShown,
      'timeEntries': timeEntries.map((entry) => {
        'start': entry['start']?.toIso8601String(),
        'end': entry['end']?.toIso8601String(),
      }).toList(),
    };
  }
  
  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      estimatedHours: json['estimatedHours']?.toDouble() ?? 0.0,
      estimateInfoShown: json['estimateInfoShown'] ?? false,
      timeEntries: (json['timeEntries'] as List?)?.map((entry) {
        return {
          'start': DateTime.parse(entry['start']),
          'end': DateTime.parse(entry['end']),
        };
      }).toList() ?? [],
    );
  }
}