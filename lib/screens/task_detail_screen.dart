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
  late TextEditingController _estimatedHoursController;
  bool _isTimerRunning = false;
  DateTime? _startTime;
  String _tempEstimatedHours = '';

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.task.description);
    _estimatedHoursController = TextEditingController(
      text: widget.task.estimatedHours > 0 ? widget.task.estimatedHours.toString() : ''
    );
    
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

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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
                // Add this section to display the total time
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Time Committed',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              Text(
                                _formatDuration(widget.task.getTotalTimeSpent()),
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Work Sessions',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              Text(
                                '${widget.task.timeEntries.length}',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (widget.task.timeEntries.isNotEmpty) ...[
                            const Icon(Icons.av_timer, color: Colors.blue),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Avg Session Time',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                Text(
                                  _formatDuration(widget.task.getTotalTimeSpent() ~/ widget.task.timeEntries.length),
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
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
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text('Estimated Hours: ', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'Hours to complete',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Estimated Hours',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      'Once set or once you begin tracking time, estimated hours cannot be changed. This helps maintain accuracy in progress tracking.',
                                      style: GoogleFonts.inter(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'OK',
                                          style: GoogleFonts.inter(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: _estimatedHoursController,
                        // Only store the value temporarily while typing
                        onChanged: (value) {
                          _tempEstimatedHours = value;
                        },
                        // Save the value when the user submits
                        onSubmitted: (value) {
                          double? parsedValue = double.tryParse(value);
                          if (parsedValue != null && parsedValue > 0) {
                            if (widget.task.estimatedHours > 0 || widget.task.timeEntries.isNotEmpty) {
                              // Show dialog that it can't be changed
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Cannot Change Estimate',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      widget.task.timeEntries.isNotEmpty
                                        ? 'Estimated hours cannot be changed after work has begun. This ensures accurate progress tracking for your tasks.'
                                        : 'Estimated hours cannot be changed once set. This ensures accurate progress tracking for your tasks.',
                                      style: GoogleFonts.inter(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'OK',
                                          style: GoogleFonts.inter(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              // Revert to original value
                              setState(() {
                                _estimatedHoursController.text = widget.task.estimatedHours.toString();
                              });
                            } else {
                              // Save the value
                              setState(() {
                                widget.task.estimatedHours = parsedValue;
                                // Update UI to show the field is now locked
                                _estimatedHoursController.text = parsedValue.toString();
                              });
                            }
                          }
                        },
                        // Disable the field if already set or if work has started
                        enabled: widget.task.estimatedHours == 0 && widget.task.timeEntries.isEmpty,
                      ),
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
                const Text('Time Tracking Statistics:', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        'Total Time Committed:',
                        _formatDuration(widget.task.getTotalTimeSpent()),
                        Icons.access_time,
                      ),
                      const Divider(),
                      _buildStatRow(
                        'Work Sessions:',
                        '${widget.task.timeEntries.length}',
                        Icons.calendar_today,
                      ),
                      if (widget.task.timeEntries.isNotEmpty) ...[
                        const Divider(),
                        _buildStatRow(
                          'Average Session Length:',
                          _formatDuration(widget.task.getTotalTimeSpent() ~/ widget.task.timeEntries.length),
                          Icons.av_timer,
                        ),
                      ],
                      // Add this to the time tracking statistics container
                      if (widget.task.estimatedHours > 0) ...[
                        const Divider(),
                        _buildStatRow(
                          'Estimated Time:',
                          '${widget.task.estimatedHours} hours',
                          Icons.timer_outlined,
                        ),
                        const Divider(),
                        _buildStatRow(
                          'Progress:',
                          '${(widget.task.getProgressPercentage() * 100).toStringAsFixed(1)}%',
                          Icons.trending_up,
                        ),
                      ],
                    ],
                  ),
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
                Container(
                  height: 200, // Fixed height for the time logs section
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
                const SizedBox(height: 10), // Add some bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}