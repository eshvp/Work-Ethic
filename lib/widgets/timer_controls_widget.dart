import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerControlsWidget extends StatelessWidget {
  final bool isTimerRunning;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const TimerControlsWidget({
    super.key,
    required this.isTimerRunning,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: isTimerRunning ? null : onStart,
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
          onPressed: isTimerRunning ? onStop : null,
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
    );
  }
}
