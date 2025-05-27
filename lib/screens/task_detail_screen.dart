import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  label: Text(
                    'Start Time', 
                    style: GoogleFonts.inter(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isTimerRunning ? _stopTimer : null,
                  icon: const Icon(Icons.stop),
                  label: Text(
                    'Stop Time',
                    style: GoogleFonts.inter(),
                  ),
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
                  style: GoogleFonts.inter(
                    fontStyle: FontStyle.italic,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            const Text('Time Logs:', 
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.task.timeEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No time entries yet',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.task.timeEntries.length,
                      itemBuilder: (context, index) {
                        final entry = widget.task.timeEntries[index];
                        final duration = entry['end']!.difference(entry['start']!);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Time started at: ${_formatDateTime(entry['start']!)}',
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                  Text(
                                    'Time stopped at: ${_formatDateTime(entry['end']!)}',
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                  const Divider(),
                                  Text(
                                    'You worked for: ${_formatDuration(duration)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
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
    );
  }
}