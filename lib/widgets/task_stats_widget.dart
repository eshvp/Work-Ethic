import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';

class TaskStatsWidget extends StatelessWidget {
  final Task task;
  final String Function(Duration) formatDuration;

  const TaskStatsWidget({
    super.key,
    required this.task,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    formatDuration(task.getTotalTimeSpent()),
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
                    '${task.timeEntries.length}',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (task.timeEntries.isNotEmpty) ...[
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
                      formatDuration(task.getTotalTimeSpent() ~/ task.timeEntries.length),
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
    );
  }
}
