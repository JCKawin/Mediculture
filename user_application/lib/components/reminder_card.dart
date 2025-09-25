
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReminderCard extends StatelessWidget {
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color lightPurple = Color(0xFFE8E2FF);
  static const Color darkPurple = Color(0xFF6C5CE7);
  static const Color ivory = Color(0xFFFFFDF7);

  final int index;

  const ReminderCard({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reminderData = _getReminderData(index);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            ivory.withValues(alpha: .8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: .1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white,
            spreadRadius: -2,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        border: Border.all(
          color: lightPurple.withValues(alpha: .3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Time indicator
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  reminderData['color'].withValues(alpha: .2),
                  reminderData['color'].withValues(alpha: .1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: reminderData['color'].withValues(alpha: .3),
                width: 1,
              ),
            ),
            child: Icon(
              reminderData['icon'],
              color: reminderData['color'],
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminderData['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  reminderData['time'],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: reminderData['color'].withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: reminderData['color'].withValues(alpha: .3),
                width: 1,
              ),
            ),
            child: Text(
              'Pending',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: reminderData['color'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getReminderData(int index) {
    final reminders = [
      {
        'title': 'Take Vitamin D',
        'time': '8:00 AM',
        'icon': Icons.medication_rounded,
        'color': Colors.orange,
      },
      {
        'title': 'Blood Pressure Check',
        'time': '2:00 PM',
        'icon': Icons.monitor_heart_rounded,
        'color': Colors.red,
      },
      {
        'title': 'Evening Walk',
        'time': '6:30 PM',
        'icon': Icons.directions_walk_rounded,
        'color': Colors.green,
      },
      {
        'title': 'Drink Water',
        'time': 'Every 2 hours',
        'icon': Icons.water_drop_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Take Medication',
        'time': '9:00 PM',
        'icon': Icons.medical_services_rounded,
        'color': primaryPurple,
      },
    ];

    return reminders[index % reminders.length];
  }
}
