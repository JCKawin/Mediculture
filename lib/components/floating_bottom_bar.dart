import 'package:flutter/material.dart';

class FloatingBottomBar extends StatelessWidget {
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color darkPurple = Color(0xFF6C5CE7);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryPurple, darkPurple],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha:0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomBarItem(Icons.home_rounded, true),
          _buildBottomBarItem(Icons.favorite_rounded, false),
          _buildBottomBarItem(Icons.calendar_today_rounded, false),
          _buildBottomBarItem(Icons.person_rounded, false),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem(IconData icon, bool isActive) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha:0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}
