
import 'package:flutter/material.dart';
import 'package:mediculture_app/components/custom_app_bar.dart';
import 'package:mediculture_app/components/floating_search_bar.dart';
import 'package:mediculture_app/components/reminder_card.dart';
import 'package:mediculture_app/components/neomorphic_button.dart';
import 'package:mediculture_app/components/sos_button.dart';
import 'package:mediculture_app/components/floating_bottom_bar.dart';
import 'package:mediculture_app/screens/community_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  // Modern color theme: Light purple and Ivory
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color lightPurple = Color(0xFFE8E2FF);
  static const Color ivory = Color(0xFFFFFDF7);
  static const Color darkPurple = Color(0xFF6C5CE7);
  static const Color softGrey = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lightPurple.withValues(alpha: .3),
                  ivory,
                  ivory,
                ],
              ),
            ),
          ),
          // Main content
          CustomScrollView(
            slivers: [
              // Custom App Bar
              CustomAppBar(),

              // Body content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),

                      // Floating Search Bar
                      FloatingSearchBar(),

                      SizedBox(height: 20),

                      // Daily Reminder Section
                      Text(
                        'Daily Reminder',
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: darkPurple,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Scrollable reminder cards
                      Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: 5,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return ReminderCard(index: index);
                          },
                        ),
                      ),

                      SizedBox(height: 27),

                      // Quick Actions Title
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: darkPurple,
                          letterSpacing: 0.5,
                        ),
                      ),
                      // SizedBox(height: 10),

                      // Neomorphic Buttons Grid
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.1,
                        children: [
                          NeomorphicButton(
                            title: 'Community',
                            icon: Icons.people_alt_rounded,
                            onTap: () => _handleButtonTap(context, 'Community'),
                          ),
                          SOSButton(
                            onTap: () => _handleSOSTap(context),
                          ),
                          NeomorphicButton(
                            title: 'Buy Medicine',
                            icon: Icons.medical_services_rounded,
                            onTap: () => _handleButtonTap(context, 'Buy Medicine'),
                          ),
                          NeomorphicButton(
                            title: """Appointment""",
                            icon: Icons.calendar_today_rounded,
                            onTap: () => _handleButtonTap(context, 'Book Appointment'),
                          ),
                          
                        ],
                      ),

                      SizedBox(height: 110), // Extra space for bottom bar
                    ],
                    
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingBottomBar(),
          ),
        ],
      ),
    );
  }

  void _handleButtonTap(BuildContext context, String title) {
  Navigator.push(context , MaterialPageRoute(builder: (context) => CommunityPage()));
  }

  void _handleSOSTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Emergency SOS Activated!'),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
