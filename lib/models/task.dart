class Task {
  final String id;
  final String title;
  String description;
  bool isCompleted;
  List<Map<String, DateTime>> timeEntries;
  double estimatedHours; // Add estimated hours property

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.estimatedHours = 0.0, // Default to 0 hours
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
  
  // Calculate progress based on estimated hours
  double getProgressPercentage() {
    if (isCompleted) return 1.0; // If task is completed, return 100%
    if (estimatedHours <= 0) return 0.1; // If no estimate, show minimum progress
    
    final hoursSpent = getTotalTimeSpent().inMinutes / 60.0;
    final progress = hoursSpent / estimatedHours;
    
    // Cap at 99% if not marked as completed
    if (progress >= 0.99 && !isCompleted) return 0.99;
    // Ensure progress is between 0 and 1
    return progress.clamp(0.0, 1.0);
  }
}