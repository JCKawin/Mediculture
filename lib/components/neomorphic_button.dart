
import 'package:flutter/material.dart';

class NeomorphicButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const NeomorphicButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  _NeomorphicButtonState createState() => _NeomorphicButtonState();
}

class _NeomorphicButtonState extends State<NeomorphicButton> {
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color lightPurple = Color(0xFFE8E2FF);
  static const Color darkPurple = Color(0xFF6C5CE7);
  static const Color ivory = Color(0xFFFFFDF7);

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isPressed
                ? [
                    lightPurple.withValues(alpha: .8),
                    lightPurple,
                  ]
                : [
                    Colors.white,
                    lightPurple.withValues(alpha: .3),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: primaryPurple.withValues(alpha: .2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(-2, -2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: primaryPurple.withValues(alpha: .15),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: Offset(5, 5),
                  ),
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: Offset(-5, -5),
                  ),
                ],
          border: Border.all(
            color: lightPurple.withValues(alpha: .3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple.withValues(alpha: .2), primaryPurple.withValues(alpha: .1)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withValues(alpha: .1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 32,
                color: darkPurple,
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: darkPurple,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
