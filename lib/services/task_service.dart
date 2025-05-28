import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'work_ethic_tasks';
  
  // Save all tasks to storage
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }
  
  // Load all tasks from storage
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey);
    
    if (tasksJson == null || tasksJson.isEmpty) {
      return [];
    }
    
    return tasksJson.map((taskJson) {
      final taskMap = jsonDecode(taskJson);
      return Task.fromJson(taskMap);
    }).toList();
  }
}