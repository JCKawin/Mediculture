import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediculture_app/components/floating_bottom_bar.dart';
import 'package:mediculture_app/services/api_service.dart';
import 'package:mediculture_app/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color lightPurple = Color(0xFFE8E2FF);
  static const Color ivory = Color(0xFFFFFDF7);
  static const Color darkPurple = Color(0xFF6C5CE7);

  final AuthService _authService = AuthService();
  
  // User data from database
  Map<String, dynamic>? userData;
  List<dynamic> recentAppointments = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load user profile from MongoDB
      final profile = await ApiService.getUserProfile();
      final appointments = await ApiService.getUserAppointments();

      setState(() {
        userData = profile;
        recentAppointments = appointments ?? [];
        isLoading = false;
      });

      print('Loaded user data: $userData');
      print('Loaded appointments: $recentAppointments');

    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load profile data';
      });
    }
  }

  // Get user's display name from Firebase Auth or database
  String get displayName {
    if (userData != null && userData!['displayName'] != null) {
      return userData!['displayName'];
    }
    return _authService.currentUserDisplayName.isNotEmpty 
        ? _authService.currentUserDisplayName 
        : 'User';
  }

  // Get user's email
  String get userEmail {
    if (userData != null && userData!['email'] != null) {
      return userData!['email'];
    }
    return _authService.currentUserEmail;
  }

  // Calculate age from date of birth
  String get userAge {
    if (userData != null && userData!['dateOfBirth'] != null) {
      DateTime dob = DateTime.parse(userData!['dateOfBirth']);
      int age = DateTime.now().year - dob.year;
      if (DateTime.now().month < dob.month || 
          (DateTime.now().month == dob.month && DateTime.now().day < dob.day)) {
        age--;
      }
      return age.toString();
    }
    return '25'; // Default
  }

  // Get user's medical info
  Map<String, dynamic> get medicalInfo {
    return userData?['medicalInfo'] ?? {};
  }

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
                  lightPurple.withValues(alpha: 0.3),
                  ivory,
                  ivory,
                ],
              ),
            ),
          ),
          // Show loading or content
          if (isLoading)
            _buildLoadingState()
          else if (errorMessage.isNotEmpty)
            _buildErrorState()
          else
            _buildContent(),
          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingBottomBar(currentIndex: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryPurple),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: darkPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            errorMessage,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
            ),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildProfileHeader(),
                SizedBox(height: 30),
                _buildHealthStats(),
                SizedBox(height: 30),
                _buildQuickActions(),
                SizedBox(height: 30),
                _buildRecentActivity(),
                SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryPurple, darkPurple],
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
                    color: Colors.white.withValues(alpha: 0.1),
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
                          'PROFILE',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your health journey',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showEditProfileDialog(),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
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

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(24),
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryPurple.withValues(alpha: 0.2),
                  primaryPurple.withValues(alpha: 0.1)
                ],
              ),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: primaryPurple.withValues(alpha: 0.3), width: 2),
            ),
            child: userData?['photoURL'] != null && userData!['photoURL'].isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: Image.network(
                      userData!['photoURL'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: primaryPurple,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: primaryPurple,
                  ),
          ),
          SizedBox(height: 16),
          Text(
            displayName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: darkPurple,
            ),
          ),
          SizedBox(height: 4),
          Text(
            userEmail,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: lightPurple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userData?['membershipType'] ?? 'Basic Member',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkPurple,
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfileStat('Age', userAge),
              _buildProfileStat(
                'Height', 
                userData?['height'] ?? '5\'8"'
              ),
              _buildProfileStat(
                'Weight', 
                userData?['weight'] ?? '70kg'
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryPurple,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthStats() {
    // Get health data from database or use defaults
    final healthData = userData?['healthStats'] ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Overview',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkPurple,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildHealthCard(
                'Blood Pressure',
                healthData['bloodPressure'] ?? '120/80',
                'mmHg',
                Colors.red,
                Icons.favorite,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildHealthCard(
                'Heart Rate',
                healthData['heartRate'] ?? '72',
                'bpm',
                Colors.pink,
                Icons.monitor_heart,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildHealthCard(
                'Blood Sugar',
                healthData['bloodSugar'] ?? '95',
                'mg/dL',
                Colors.orange,
                Icons.water_drop,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildHealthCard(
                'BMI',
                _calculateBMI(),
                _getBMIStatus(),
                Colors.green,
                Icons.straighten,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _calculateBMI() {
    if (userData?['weight'] != null && userData?['height'] != null) {
      // Simple BMI calculation (you'd need to parse height and weight properly)
      return '22.4'; // Placeholder
    }
    return '22.4';
  }

  String _getBMIStatus() {
    double bmi = 22.4; // You'd calculate this properly
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Widget _buildHealthCard(String title, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkPurple,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkPurple,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                spreadRadius: 0,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            children: [
              _buildActionItem(Icons.medical_information, 'Medical Records', 'View your health records'),
              _buildActionItem(Icons.receipt_long, 'Order History', 'Track your past orders'),
              _buildActionItem(Icons.favorite_border, 'Health Goals', 'Set and track goals'),
              _buildActionItem(Icons.family_restroom, 'Family Health', 'Manage family profiles'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Handle action tap
          print('Tapped: $title');
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryPurple, size: 22),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkPurple,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: darkPurple,
                letterSpacing: 0.3,
              ),
            ),
            if (recentAppointments.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to full activity list
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        
        // Show real appointment data or placeholder
        if (recentAppointments.isEmpty)
          _buildEmptyActivityState()
        else
          ...recentAppointments.take(3).map((appointment) => _buildActivityItem(
            appointment['type'] ?? 'Appointment',
            appointment['doctorName'] ?? 'Doctor Appointment',
            _formatAppointmentDate(appointment['appointmentDate']),
            appointment['status'] ?? 'scheduled',
          )).toList(),
      ],
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No recent activity',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Book an appointment or order medicines to see your activity here',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String type, String title, String date, String status) {
    Color statusColor = primaryPurple;
    if (status == 'completed') statusColor = Colors.green;
    if (status == 'cancelled') statusColor = Colors.red;
    if (status == 'confirmed') statusColor = Colors.blue;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      type,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • $date',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAppointmentDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return 'Today';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        return 'Yesterday';
      } else {
        int daysAgo = now.difference(date).inDays;
        return '$daysAgo days ago';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Text('Profile editing will be implemented here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
