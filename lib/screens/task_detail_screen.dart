import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:isolate';
import '../models/task.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/task_stats_widget.dart';
import '../widgets/time_logs_widget.dart';
import '../widgets/timer_controls_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedHoursController;
  bool _isTimerRunning = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.task.description);
    _estimatedHoursController = TextEditingController(
      text: widget.task.estimatedHours > 0 ? widget.task.estimatedHours.toString() : ''
    );

    _initForegroundTask();
    _initializeForegroundTaskListener();

    // Request permissions on the first task
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionsIfNeeded();
    });

    // Show the info snackbar after the screen has finished building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First, close any existing snackbars to prevent stacking
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      // Only show the notification if estimated hours haven't been set yet
      // AND the info hasn't been shown for this task yet
      if (widget.task.estimatedHours == 0 && 
          widget.task.timeEntries.isEmpty && 
          !widget.task.estimateInfoShown && 
          mounted) {
        
        // Mark this task as having shown the info
        widget.task.estimateInfoShown = true;
        
        // Show snackbar explaining the estimated hours feature
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Set your estimated hours before starting work. Once set or once work begins, estimates cannot be changed.',
                    style: GoogleFonts.inter(),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 10),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'GOT IT',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  void _startForegroundServiceForTask(String taskId, String taskTitle) {
    FlutterForegroundTask.startService(
      notificationTitle: 'Task: $taskTitle',
      notificationText: 'Tracking time for task $taskTitle...',
      callback: startCallback,
    );
    FlutterForegroundTask.saveData(key: 'currentTaskId', value: taskId);
  }

  void _stopForegroundServiceForTask(String taskId) async {
    final currentTaskId = await FlutterForegroundTask.getData<String>(key: 'currentTaskId');
    if (currentTaskId == taskId) {
      FlutterForegroundTask.stopService();
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _startTime = DateTime.now();
    });

    // Start the foreground service for the specific task
    _startForegroundServiceForTask(widget.task.id, widget.task.title);
  }

  void _stopTimer() {
    if (_startTime != null) {
      final endTime = DateTime.now();

      setState(() {
        widget.task.timeEntries.add({
          'start': _startTime!,
          'end': endTime,
        });
        _isTimerRunning = false;
        _startTime = null;
      });

      // Stop the foreground service for the specific task
      _stopForegroundServiceForTask(widget.task.id);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM d, yyyy HH:mm:ss');
    return formatter.format(dateTime);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Updated _initForegroundTask to initialize at app startup
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'work_ethic_timer',
        channelName: 'Work Ethic Timer',
        channelDescription: 'Timer notifications for Work Ethic app',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        interval: 1000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  void _initializeForegroundTaskListener() async {
    final receivePort = await FlutterForegroundTask.receivePort;
    receivePort?.listen((data) {
      if (data is String) {
        if (data == 'pause_resume') {
          if (_isTimerRunning) {
            _pauseTimer();
          } else {
            _resumeTimer();
          }
        } else if (data == 'stop') {
          _stopTimer();
        }
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isTimerRunning = false;
    });
    FlutterForegroundTask.updateService(
      notificationTitle: 'Work Ethic Timer',
      notificationText: 'Timer paused.',
    );
  }

  void _resumeTimer() {
    setState(() {
      _isTimerRunning = true;
    });
    FlutterForegroundTask.updateService(
      notificationTitle: 'Work Ethic Timer',
      notificationText: 'Timer resumed.',
    );
  }

  void _requestPermissionsIfNeeded() async {
    // Check and request notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        _showPermissionDialog(
          'Notifications are blocked. Please enable notifications in the app settings.',
          openNotificationSettings: true,
        );
        return;
      }
    }

    // Check and request battery optimization ignore permission (Android only)
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Inform users about "Pause App Activity if Unused" setting
    _showPermissionDialog(
      'To ensure the app works correctly, please disable the "Pause app activity if unused" setting in your system settings.',
    );
  }

  void _showPermissionDialog(String message, {bool openNotificationSettings = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          if (openNotificationSettings)
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open Notification Settings'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskStatsWidget(
                  task: widget.task,
                  formatDuration: _formatDuration,
                ),
                const SizedBox(height: 20),
                TimerControlsWidget(
                  isTimerRunning: _isTimerRunning,
                  onStart: _startTimer,
                  onStop: _stopTimer,
                ),
                const SizedBox(height: 20),
                TimeLogsWidget(
                  timeEntries: widget.task.timeEntries,
                  formatDateTime: _formatDateTime,
                  formatDuration: _formatDuration,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isTimerRunning) {
                        _stopTimer();
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text(
                      'Save and Return',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Added startCallback function as a top-level function
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(WorkEthicTaskHandler());
}

// Added WorkEthicTaskHandler class to handle foreground task events
class WorkEthicTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    if (sendPort != null) {
      FlutterForegroundTask.saveData(key: 'sendPort', value: sendPort);
    }
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Logic for periodic events
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Cleanup logic when the foreground task is destroyed
  }

  @override
  void onButtonPressed(String id) async {
    final sendPort = await FlutterForegroundTask.getData<SendPort>(key: 'sendPort');
    if (id == 'pause_resume') {
      sendPort?.send('pause_resume');
    } else if (id == 'stop') {
      sendPort?.send('stop');
    }
  }
}