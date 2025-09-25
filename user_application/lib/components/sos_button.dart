import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_glow/avatar_glow.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget? screenWidget;

  const SOSButton({
    Key? key,
    required this.onTap,
    this.screenWidget,
  }) : super(key: key);

  @override
  _SOSButtonState createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  static const Color primaryPurple = Color.fromARGB(255, 103, 74, 249);
  static const Color lightPurple = Color(0xFFFF0000);
  static const Color darkPurple = Color(0xFF6C5CE7);
  static const Color ivory = Color(0xFFFFFDF7);

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (widget.screenWidget != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => widget.screenWidget!),
          );
        } else {
          widget.onTap();
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: .8),
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: _isPressed
          //       ? [
          //           lightPurple.withValues(alpha: .8),
          //           lightPurple,
          //         ]
          //       : [
          //           Colors.white,
          //           lightPurple.withValues(alpha: .3),
          //         ],
          // ),
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
            color: Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Neomorphic inner container with glow around the icon
            AvatarGlow(
              glowColor: Colors.white12,
              endRadius: 42,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: false,
              repeatPauseDuration: Duration(milliseconds: 100),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // NEOMORPHIC INNER CONTAINER
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white12,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  // NEOMORPHIC INNER SHADOWS
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withValues(alpha: .1),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: Offset(-2, -2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 40,
                  color: Colors.deepOrangeAccent,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'SOS',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),


    );
  }
}
