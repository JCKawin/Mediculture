
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';


class SOSButton extends StatefulWidget {
  final VoidCallback onTap;

  const SOSButton({Key? key, required this.onTap}) : super(key: key);

  @override
  _SOSButtonState createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      glowColor: Colors.deepOrange,
      endRadius: 90.0,
      duration: Duration(milliseconds: 2000),
      repeat: true,
      showTwoGlows: true,
      repeatPauseDuration: Duration(milliseconds: 100),
      child: GestureDetector(
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
                      Colors.deepOrange.shade700,
                      Colors.deepOrange.shade500,
                    ]
                  : [
                      Colors.deepOrange.shade600,
                      Colors.deepOrange.shade400,
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: Colors.deepOrange.withValues(alpha: .4),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.deepOrange.withValues(alpha: .4),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.deepOrange.withValues(alpha: .2),
                      spreadRadius: 0,
                      blurRadius: 40,
                      offset: Offset(0, 16),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'SOS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: .3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Emergency',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: .9),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


