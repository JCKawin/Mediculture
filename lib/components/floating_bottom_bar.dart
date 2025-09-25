import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediculture_app/screens/home_screen.dart';
import 'package:mediculture_app/screens/community_screen.dart';
import 'package:mediculture_app/screens/settings_screen.dart';
import 'package:mediculture_app/screens/profile_screen.dart';

class FloatingBottomBar extends StatefulWidget {
  final int currentIndex;
  
  const FloatingBottomBar({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  _FloatingBottomBarState createState() => _FloatingBottomBarState();
}

class _FloatingBottomBarState extends State<FloatingBottomBar> {
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color darkPurple = Color(0xFF6C5CE7);

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (selectedIndex == index) return; // Don't navigate if same page
    
    setState(() {
      selectedIndex = index;
    });

    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = HomePage();
        break;
      case 1:
        targetScreen = ProfileScreen();
        break;
      case 2:
        targetScreen = SettingsScreen();
        break;
      default:
        targetScreen = HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

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
            color: primaryPurple.withValues(alpha: .3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomBarItem(Icons.home_rounded, 'Home', 0),
          // _buildBottomBarItem(Icons.people_alt_rounded, 'Community', 1),
          _buildBottomBarItem(Icons.person_rounded, 'Profile', 1),
          _buildBottomBarItem(Icons.settings_rounded, 'Settings', 2),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem(IconData icon, String label, int index) {
    bool isActive = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: .2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
