import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:intl/intl.dart'; // Add this dependency to pubspec.yaml

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _descriptionController;
  bool _isTimerRunning = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _startTime = DateTime.now();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Completed: ', style: TextStyle(fontSize: 18)),
                Checkbox(
                  value: widget.task.isCompleted,
                  onChanged: (value) {
                    setState(() {
                      widget.task.isCompleted = value ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Description:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add description...',
              ),
              maxLines: 5,
              onChanged: (value) {
                widget.task.description = value;
              },
            ),
            const SizedBox(height: 20),
            const Text('Time Tracking:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isTimerRunning ? null : _startTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isTimerRunning ? _stopTimer : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            if (_isTimerRunning && _startTime != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Time started at: ${_formatDateTime(_startTime!)}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 10),
            const Text('Time Logs:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.task.timeEntries.isEmpty
                  ? const Center(child: Text('No time entries yet'))
                  : ListView.builder(
                      itemCount: widget.task.timeEntries.length,
                      itemBuilder: (context, index) {
                        final entry = widget.task.timeEntries[index];
                        final duration = entry['end']!.difference(entry['start']!);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Time started at: ${_formatDateTime(entry['start']!)}'),
                                  Text('Time stopped at: ${_formatDateTime(entry['end']!)}'),
                                  const Divider(),
                                  Text(
                                    'You worked for: ${_formatDuration(duration)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
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
                child: const Text('Save and Return'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}