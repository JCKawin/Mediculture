
import 'package:flutter/material.dart';

class FloatingSearchBar extends StatelessWidget {
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color lightPurple = Color(0xFFE8E2FF);
  static const Color darkPurple = Color(0xFF6C5CE7);
  static const Color ivory = Color(0xFFFFFDF7);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: .15),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white,
            spreadRadius: -5,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
        border: Border.all(
          color: lightPurple.withValues(alpha: .5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightPurple.withValues(alpha: .3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.search_rounded,
              color: darkPurple,
              size: 22,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search medicines, doctors, articles...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: darkPurple,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple, darkPurple],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withValues(alpha: .3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
