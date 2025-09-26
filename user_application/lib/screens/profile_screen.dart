import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediculture_app/components/floating_bottom_bar.dart';
import 'package:mediculture_app/services/api_service.dart';
import 'package:mediculture_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
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
    if (currentUser == null) {
      setState(() {
        errorMessage = 'User not authenticated';
        isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Create user profile if doesn't exist
      await _ensureUserProfile();

      // Load user profile and appointments from MongoDB
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

  Future<void> _ensureUserProfile() async {
    try {
      // Check if user exists in MongoDB, if not create profile
      final existingProfile = await ApiService.getUserProfile();
      
      if (existingProfile == null) {
        print('Creating new user profile for: ${currentUser!.uid}');
        // Create new user profile in MongoDB
        final newUserData = {
          'firebaseUid': currentUser!.uid,
          'email': currentUser!.email ?? '',
          'displayName': currentUser!.displayName ?? 'User',
          'phoneNumber': currentUser!.phoneNumber ?? '',
          'membershipType': 'Basic',
          'isActive': true,
          'healthStats': {
            'bloodPressure': '120/80',
            'heartRate': '72',
            'bloodSugar': '95',
            'bmi': '22.4',
            'lastUpdated': DateTime.now().toIso8601String()
          },
          'preferences': {
            'notifications': true,
            'language': 'English',
            'theme': 'Light'
          }
        };
        
        await ApiService.updateUserProfile(newUserData);
        print('User profile created successfully');
      } else {
        print('User profile already exists');
      }
    } catch (e) {
      print('Error ensuring user profile: $e');
    }
  }

  // Get user's display name from Firebase Auth or database
  String get displayName {
    if (userData != null && userData!['displayName'] != null && userData!['displayName'].toString().isNotEmpty) {
      return userData!['displayName'];
    }
    if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
      return currentUser!.displayName!;
    }
    return 'User';
  }

  // Get user's email
  String get userEmail {
    if (userData != null && userData!['email'] != null && userData!['email'].toString().isNotEmpty) {
      return userData!['email'];
    }
    return currentUser?.email ?? 'user@example.com';
  }

  // Calculate age from date of birth
  String get userAge {
    if (userData != null && userData!['dateOfBirth'] != null) {
      try {
        DateTime dob = DateTime.parse(userData!['dateOfBirth']);
        int age = DateTime.now().year - dob.year;
        if (DateTime.now().month < dob.month || 
            (DateTime.now().month == dob.month && DateTime.now().day < dob.day)) {
          age--;
        }
        return age.toString();
      } catch (e) {
        print('Error parsing date of birth: $e');
      }
    }
    return '25'; // Default
  }

  // Get user's medical info
  Map<String, dynamic> get medicalInfo {
    return userData?['medicalInfo'] ?? {};
  }

  // Get user's health stats
  Map<String, dynamic> get healthStats {
    return userData?['healthStats'] ?? {
      'bloodPressure': '120/80',
      'heartRate': '72',
      'bloodSugar': '95',
      'bmi': '22.4'
    };
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
            child: FloatingBottomBar(currentIndex: 1),
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
    return RefreshIndicator(
      onRefresh: _loadUserData,
      color: primaryPurple,
      child: CustomScrollView(
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _loadUserData,
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
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
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
                              size: 20,
                            ),
                          ),
                        ),
                      ],
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
          Stack(
            alignment: Alignment.center,
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
                child: userData?['profilePicture'] != null && userData!['profilePicture'].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(48),
                        child: Image.network(
                          userData!['profilePicture'],
                          fit: BoxFit.cover,
                          width: 96,
                          height: 96,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person_rounded,
                              size: 50,
                              color: primaryPurple,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: primaryPurple,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
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
              if (currentUser?.emailVerified == false)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
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
          if (currentUser?.emailVerified == false) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Email not verified',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                userData?['height']?.toString() ?? '5\'8"'
              ),
              _buildProfileStat(
                'Weight', 
                userData?['weight']?.toString() ?? '70kg'
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            TextButton.icon(
              onPressed: _showUpdateHealthStatsDialog,
              icon: Icon(Icons.edit, size: 16, color: primaryPurple),
              label: Text(
                'Update',
                style: GoogleFonts.poppins(
                  color: primaryPurple,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildHealthCard(
                'Blood Pressure',
                healthStats['bloodPressure'] ?? '120/80',
                'mmHg',
                Colors.red,
                Icons.favorite,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildHealthCard(
                'Heart Rate',
                healthStats['heartRate'] ?? '72',
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
                healthStats['bloodSugar'] ?? '95',
                'mg/dL',
                Colors.orange,
                Icons.water_drop,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildHealthCard(
                'BMI',
                healthStats['bmi'] ?? '22.4',
                _getBMIStatus(healthStats['bmi']),
                Colors.green,
                Icons.straighten,
              ),
            ),
          ],
        ),
        if (healthStats['lastUpdated'] != null) ...[
          SizedBox(height: 12),
          Text(
            'Last updated: ${_formatLastUpdated(healthStats['lastUpdated'])}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  String _getBMIStatus(dynamic bmiValue) {
    if (bmiValue == null) return 'Normal';
    
    double bmi;
    if (bmiValue is String) {
      bmi = double.tryParse(bmiValue) ?? 22.4;
    } else if (bmiValue is num) {
      bmi = bmiValue.toDouble();
    } else {
      return 'Normal';
    }
    
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String _formatLastUpdated(String? dateString) {
    if (dateString == null) return 'Never';
    
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
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
              _buildActionItem(Icons.settings, 'Settings', 'Manage your preferences'),
              _buildActionItem(Icons.logout, 'Sign Out', 'Sign out of your account', isSignOut: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, {bool isSignOut = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSignOut) {
            _showSignOutDialog();
          } else {
            _handleActionTap(title);
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSignOut 
                      ? Colors.red.withValues(alpha: 0.1)
                      : primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon, 
                  color: isSignOut ? Colors.red : primaryPurple, 
                  size: 22
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
                        color: isSignOut ? Colors.red : darkPurple,
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
              if (!isSignOut)
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
                  // Navigate to appointments screen
                  Navigator.pushNamed(context, '/appointments');
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
        if (isLoading)
          _buildActivitySkeleton()
        else if (recentAppointments.isEmpty)
          _buildEmptyActivityState()
        else
          ...recentAppointments.take(3).map((appointment) => _buildActivityItem(
            appointment['type'] ?? 'Appointment',
            '${appointment['doctorName'] ?? 'Doctor'} - ${appointment['specialty'] ?? 'Consultation'}',
            _formatAppointmentDate(appointment['appointmentDate']),
            appointment['status'] ?? 'scheduled',
          )).toList(),
      ],
    );
  }

  Widget _buildActivitySkeleton() {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        height: 80,
      )),
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
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/appointments');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Book Appointment',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
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
        if (daysAgo > 0) {
          return '$daysAgo days ago';
        } else {
          return '${daysAgo.abs()} days from now';
        }
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _handleActionTap(String title) {
    switch (title) {
      case 'Medical Records':
        _showComingSoonDialog('Medical Records');
        break;
      case 'Order History':
        _showComingSoonDialog('Order History');
        break;
      case 'Health Goals':
        _showComingSoonDialog('Health Goals');
        break;
      case 'Settings':
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: primaryPurple),
              SizedBox(width: 8),
              Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
            ],
          ),
          content: Text(
            'Profile editing functionality will be implemented in the next update. You can update your basic information here.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: primaryPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateHealthStatsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.health_and_safety, color: primaryPurple),
              SizedBox(width: 8),
              Text(
                'Update Health Stats',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
            ],
          ),
          content: Text(
            'Health stats updating functionality will be implemented soon. You can track your vital signs here.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: primaryPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Sign Out',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleSignOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sign Out',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.upcoming, color: primaryPurple),
              SizedBox(width: 8),
              Text(
                'Coming Soon',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
            ],
          ),
          content: Text(
            '$feature functionality will be available in the next update.',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(color: primaryPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      // Navigation will be handled automatically by AuthWrapper
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      print('Sign out error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
