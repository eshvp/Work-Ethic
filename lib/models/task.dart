class Task {
  final String id;
  final String title;
  String description;
  bool isCompleted;
  List<Map<String, DateTime>> timeEntries;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
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
}