import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_glow/avatar_glow.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with TickerProviderStateMixin {
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color lightPurple = Color(0xFFE8E2FF);
  static const Color ivory = Color(0xFFFFFDF7);
  static const Color darkPurple = Color(0xFF6C5CE7);

  late AnimationController _pulseController;
  bool isEmergencyActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  _buildMapView(),
                  SizedBox(height: 40),
                  _buildOrderTimeline(),
                  SizedBox(height: 30),
                  _buildQuickActions(),
                  SizedBox(height: 30),
                  _buildMedicalInfo(),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepOrange, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha:0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ORDER TRACKING', // Changed from 'EMERGENCY SOS'
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Track your medicine delivery', // Changed subtitle
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildMapView() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Live Tracking',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: darkPurple,
          letterSpacing: 0.5,
        ),
      ),
      SizedBox(height: 16),
      Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: lightPurple.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Replace with actual map widget or use placeholder
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      lightPurple.withValues(alpha: 0.2),
                      primaryPurple.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryPurple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: primaryPurple,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tracking Your Order',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkPurple,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ETA: 25 minutes',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Delivery vehicle indicator
              Positioned(
                top: 30,
                right: 40,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.delivery_dining,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Call Ambulance',
        'subtitle': '108',
        'icon': Icons.local_hospital,
        'color': Colors.red,
      },
      {
        'title': 'Call Police',
        'subtitle': '100',
        'icon': Icons.shield,
        'color': Colors.blue,
      },
      {
        'title': 'Fire Brigade',
        'subtitle': '101',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      },
      {
        'title': 'Share Location',
        'subtitle': 'GPS',
        'icon': Icons.location_on,
        'color': Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Emergency Actions',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: darkPurple,
            letterSpacing: 0.5,
          ),
        ),
        // SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.05,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (action['color'] as Color).withValues(alpha:0.1),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: (action['color'] as Color).withValues(alpha:0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    action['title'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkPurple,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    action['subtitle'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: action['color'] as Color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

Widget _buildOrderTimeline() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Order Status',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: darkPurple,
          letterSpacing: 0.5,
        ),
      ),
      SizedBox(height: 16),
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildTimelineItem(
              title: 'Order Placed',
              subtitle: 'We have received your order',
              time: '10:30 AM',
              isCompleted: true,
              isActive: false,
              icon: Icons.receipt_long,
            ),
            _buildTimelineItem(
              title: 'Order Confirmed',
              subtitle: 'We have confirmed your order',
              time: '10:31 AM',
              isCompleted: true,
              isActive: false,
              icon: Icons.check_circle_outline,
            ),
            _buildTimelineItem(
              title: 'Order Shipped',
              subtitle: 'We have shipped your order',
              time: '10:34 PM',
              isCompleted: true,
              isActive: true,
              icon: Icons.local_shipping,
            ),
            _buildTimelineItem(
              title: 'Delivered',
              subtitle: 'Your order has been delivered',
              time: 'Pending',
              isCompleted: false,
              isActive: false,
              icon: Icons.home,
              isLast: true,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildTimelineItem({
  required String title,
  required String subtitle,
  required String time,
  required bool isCompleted,
  required bool isActive,
  required IconData icon,
  bool isLast = false,
}) {
  Color getColor() {
    if (isCompleted) return primaryPurple;
    if (isActive) return primaryPurple;
    return Colors.grey.shade400;
  }

  return Container(
    child: Row(
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted || isActive 
                    ? primaryPurple.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: getColor(),
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: getColor(),
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted 
                    ? primaryPurple.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
              ),
          ],
        ),
        SizedBox(width: 16),
        // Content
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted || isActive 
                            ? darkPurple 
                            : Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted || isActive
                            ? lightPurple.withValues(alpha: 0.3)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isCompleted || isActive 
                              ? darkPurple 
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildMedicalInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lightPurple.withValues(alpha:0.3),
            ivory,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha:0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: lightPurple.withValues(alpha:0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryPurple.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_information,
                  color: primaryPurple,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'Medical Information',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildMedicalInfoRow('Blood Type', 'O+ Positive'),
          _buildMedicalInfoRow('Allergies', 'Penicillin, Peanuts'),
          _buildMedicalInfoRow('Medical ID', '#MED123456'),
          _buildMedicalInfoRow('Insurance', 'Health Plus Premium'),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
