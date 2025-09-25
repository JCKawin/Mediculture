import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  static const Color primaryPurple = Color(0xFF9C88FF);
  static const Color lightPurple = Color(0xFFE8E2FF);
  static const Color ivory = Color(0xFFFFFDF7);
  static const Color darkPurple = Color(0xFF6C5CE7);

  int selectedDayIndex = 0;
  String selectedTime = '';

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildSpecialtySelector(),
                  SizedBox(height: 30),
                  _buildTopDoctors(),
                  SizedBox(height: 30),
                  _buildDateSelector(),
                  SizedBox(height: 20),
                  _buildTimeSlots(),
                  SizedBox(height: 30),
                  _buildBookButton(),
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
                          'APPOINTMENTS',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Book with top doctors',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha:0.9),
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
                        Icons.medical_services_rounded,
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

  Widget _buildSpecialtySelector() {
    final specialties = [
      {'name': 'Cardiology', 'icon': Icons.favorite, 'color': Colors.red},
      {'name': 'Neurology', 'icon': Icons.psychology, 'color': Colors.purple},
      {'name': 'Orthopedic', 'icon': Icons.accessibility, 'color': Colors.blue},
      {'name': 'General', 'icon': Icons.local_hospital, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Specialty',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: darkPurple,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: specialties.length,
          itemBuilder: (context, index) {
            final specialty = specialties[index];
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (specialty['color'] as Color).withValues(alpha:0.1),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: (specialty['color'] as Color).withValues(alpha:0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (specialty['color'] as Color).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      specialty['icon'] as IconData,
                      color: specialty['color'] as Color,
                      size: 28,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    specialty['name'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: darkPurple,
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

  Widget _buildTopDoctors() {
    final doctors = [
      {
        'name': 'Dr. Sarah Johnson',
        'specialty': 'Cardiologist',
        'rating': '4.9',
        'experience': '15 years',
        'fee': '₹800',
        'color': Colors.red,
      },
      {
        'name': 'Dr. Michael Chen',
        'specialty': 'Neurologist',
        'rating': '4.8',
        'experience': '12 years',
        'fee': '₹1200',
        'color': Colors.blue,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Doctors',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: darkPurple,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16),
        ...doctors.map((doctor) => Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha:0.08),
                spreadRadius: 0,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha:0.1), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: (doctor['color'] as Color).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: (doctor['color'] as Color).withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: doctor['color'] as Color,
                  size: 35,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: darkPurple,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      doctor['specialty'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          doctor['rating'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          doctor['experience'] as String,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    doctor['fee'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Material(
                    child: InkWell(
                      onTap: () => {
                        // print("object")
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryPurple, darkPurple],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Select',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildDateSelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final dates = ['24', '25', '26', '27', '28'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkPurple,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedDayIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedDayIndex = index),
                child: Container(
                  width: 60,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryPurple : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                          ? primaryPurple.withValues(alpha:0.3)
                          : Colors.grey.withValues(alpha:0.1),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected 
                        ? primaryPurple 
                        : Colors.grey.withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        dates[index],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : darkPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    final morningSlots = ['9:00 AM', '10:30 AM', '11:00 AM'];
    final eveningSlots = ['2:00 PM', '4:30 PM', '6:00 PM'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Slots',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkPurple,
          ),
        ),
        SizedBox(height: 16),
        _buildTimeSlotSection('Morning', morningSlots),
        SizedBox(height: 20),
        _buildTimeSlotSection('Evening', eveningSlots),
      ],
    );
  }

  Widget _buildTimeSlotSection(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((time) {
            bool isSelected = selectedTime == time;
            return GestureDetector(
              onTap: () => setState(() => selectedTime = time),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryPurple : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                        ? primaryPurple.withValues(alpha:0.3)
                        : Colors.grey.withValues(alpha:0.1),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isSelected 
                      ? primaryPurple 
                      : Colors.grey.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : darkPurple,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: darkPurple,
        // gradient: LinearGradient(
        //   colors: [primaryPurple, darkPurple],
        // ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha:0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        'Book Appointment - ₹800',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
