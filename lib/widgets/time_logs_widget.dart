import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeLogsWidget extends StatelessWidget {
  final List<Map<String, DateTime>> timeEntries;
  final String Function(DateTime) formatDateTime;
  final String Function(Duration) formatDuration;

  const TimeLogsWidget({
    super.key,
    required this.timeEntries,
    required this.formatDateTime,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: timeEntries.isEmpty
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
              itemCount: timeEntries.length,
              itemBuilder: (context, index) {
                final entry = timeEntries[index];
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
                            'Time started at: ${formatDateTime(entry['start']!)}',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          Text(
                            'Time stopped at: ${formatDateTime(entry['end']!)}',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          const Divider(),
                          Text(
                            'You worked for: ${formatDuration(duration)}',
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
    );
  }
}
