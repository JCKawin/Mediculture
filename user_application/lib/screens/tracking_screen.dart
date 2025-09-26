import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:mediculture_app/services/emergency_service.dart';
import 'dart:async';
import 'dart:math';

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

  // Map related variables
  MapController mapController = MapController();
  Location location = Location();
  List<Marker> markers = [];
  List<Polyline> polylines = [];
  LatLng? currentPosition;
  LatLng? deliveryLocation;
  LatLng? pharmacyLocation;
  LocationData? currentLocationData; // Store actual LocationData for SMS

  // Delivery tracking
  Timer? _trackingTimer;
  String estimatedTime = "25 minutes";
  double deliveryProgress = 0.6; // 60% delivered
  bool isLocationPermissionGranted = false;

  // SOS related variables
  bool isSOSActive = false;
  bool isSOSCooldown = false;

  List<EmergencyContact> get emergencyContacts => EmergencyService.emergencyContacts;
  Map<String, dynamic> get userMedicalInfo => EmergencyService.userMedicalInfo;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _initializeLocation();
    _startDeliveryTracking();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _trackingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      setState(() {
        isLocationPermissionGranted = true;
      });

      LocationData currentLocation = await location.getLocation();

      setState(() {
        currentLocationData = currentLocation;
        currentPosition = LatLng(
          currentLocation.latitude ?? 12.9716,
          currentLocation.longitude ?? 77.5946,
        );
        pharmacyLocation = LatLng(
          currentPosition!.latitude + 0.01,
          currentPosition!.longitude + 0.01,
        );
        deliveryLocation = LatLng(
          pharmacyLocation!.latitude - (0.01 * (1 - deliveryProgress)),
          pharmacyLocation!.longitude - (0.01 * (1 - deliveryProgress)),
        );
      });

      _updateMapMarkers();
      // ✅ FIX 3: Removed call from here. It's now handled by onMapReady.
      // _moveMapToShowAllMarkers();

    } catch (e) {
      print('Error initializing location: $e');
    }
  }

  void _updateMapMarkers() {
    markers.clear();
    polylines.clear();

    if (currentPosition != null) {
      markers.add(
        Marker(
          point: currentPosition!,
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.person, color: Colors.white, size: 25),
          ),
        ),
      );
    }

    if (pharmacyLocation != null) {
      markers.add(
        Marker(
          point: pharmacyLocation!,
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.local_pharmacy, color: Colors.white, size: 30),
          ),
        ),
      );
    }

    if (deliveryLocation != null) {
      markers.add(
        Marker(
          point: deliveryLocation!,
          width: 60,
          height: 60,
          child: AvatarGlow(
            endRadius: 30.0,
            animate: true,
            glowColor: Colors.red,
            duration: Duration(milliseconds: 2000),
            repeat: true,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(Icons.delivery_dining, color: Colors.white, size: 30),
            ),
          ),
        ),
      );
    }

    if (pharmacyLocation != null && currentPosition != null) {
      polylines.add(
        Polyline(
          points: [pharmacyLocation!, currentPosition!],
          strokeWidth: 3.0,
          color: primaryPurple.withOpacity(0.6),
        ),
      );
    }

    if (pharmacyLocation != null && deliveryLocation != null) {
      polylines.add(
        Polyline(
          points: [pharmacyLocation!, deliveryLocation!],
          strokeWidth: 4.0,
          color: Colors.green,
        ),
      );
    }

    if (mounted) {
        setState(() {});
    }
  }

  // ✅ FIX 1: Removed the erroneous `.ready` check.
  void _moveMapToShowAllMarkers() {
    if (currentPosition != null && pharmacyLocation != null) {
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(currentPosition!, pharmacyLocation!),
          padding: EdgeInsets.all(50.0),
        ),
      );
    }
  }

  void _startDeliveryTracking() {
    _trackingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted && deliveryLocation != null && currentPosition != null) {
        if (deliveryProgress >= 1.0) {
          timer.cancel();
          setState(() {
            estimatedTime = "Delivered";
          });
          return;
        }

        setState(() {
          deliveryProgress = min(1.0, deliveryProgress + 0.05);

          deliveryLocation = LatLng(
              pharmacyLocation!.latitude + (currentPosition!.latitude - pharmacyLocation!.latitude) * deliveryProgress,
              pharmacyLocation!.longitude + (currentPosition!.longitude - pharmacyLocation!.longitude) * deliveryProgress
          );

          int remainingMinutes = ((1.0 - deliveryProgress) * 25).round();
          estimatedTime = remainingMinutes > 0 ? "$remainingMinutes minutes" : "Arriving soon";
        });

        _updateMapMarkers();
      }
    });
  }

  Future<SOSResult> _sendEmergencySMS() async {
    try {
      final SOSResult result = await EmergencyService.sendEmergencySOSWithLocation(currentLocationData);
      return result;
    } catch (e) {
      print('Error in _sendEmergencySMS: $e');
      return SOSResult(
        success: false,
        message: 'Error: ${e.toString()}',
        sentTo: [],
      );
    }
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
                  // Removed _buildDeliveryInfo as it's redundant with the timeline
                  _buildQuickActions(),
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
      backgroundColor: Colors.transparent, // Make it transparent to show the container below
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
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
                    // ✅ FIX: Replaced withValues with withOpacity
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ORDER TRACKING',
                            style: GoogleFonts.dmSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Track your medicine delivery',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              // ✅ FIX: Replaced withValues with withOpacity
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // ✅ FIX: Replaced withValues with withOpacity
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            // ✅ FIX: Replaced withValues with withOpacity
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Live Tracking', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: darkPurple, letterSpacing: 0.5)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withOpacity(0.3))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  SizedBox(width: 6),
                  Text('Live', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.1), spreadRadius: 0, blurRadius: 15, offset: Offset(0, 5))],
            border: Border.all(color: lightPurple.withOpacity(0.3), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: isLocationPermissionGranted && currentPosition != null
                ? FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: currentPosition!,
                      initialZoom: 14.0,
                      // ✅ FIX 2: Use onMapReady to safely call map functions.
                      onMapReady: () {
                        _moveMapToShowAllMarkers();
                      },
                      interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.mediculture_app',
                      ),
                      PolylineLayer(polylines: polylines),
                      MarkerLayer(markers: markers),
                    ],
                  )
                : _buildMapPlaceholder(),
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: lightPurple.withOpacity(0.3))),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.delivery_dining, color: Colors.orange, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery Partner: Rajesh', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: darkPurple)),
                    Text('ETA: $estimatedTime', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _handleCallDelivery(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.call, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // ✅ FIX: Replaced withValues with withOpacity
            lightPurple.withOpacity(0.2),
            primaryPurple.withOpacity(0.1),
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
                // ✅ FIX: Replaced withValues with withOpacity
                color: primaryPurple.withOpacity(0.2),
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
              isLocationPermissionGranted ? 'Loading Map...' : 'Enable Location',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkPurple,
              ),
            ),
            SizedBox(height: 4),
            Text(
              isLocationPermissionGranted
                  ? 'Please wait'
                  : 'Allow location access to track delivery',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (!isLocationPermissionGranted) ...[
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _initializeLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Enable Location',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'SOS Emergency',
        'subtitle': 'Send Alert',
        'icon': Icons.sos,
        'color': Colors.red,
        'isEmergency': true,
      },
      {
        'title': 'Call 108',
        'subtitle': 'Ambulance',
        'icon': Icons.local_hospital,
        'color': Colors.red.shade700,
        'phoneNumber': '108',
      },
      {
        'title': 'Call 100',
        'subtitle': 'Police',
        'icon': Icons.shield,
        'color': Colors.blue,
        'phoneNumber': '100',
      },
      {
        'title': 'Call 101',
        'subtitle': 'Fire Brigade',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'phoneNumber': '101',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Actions',
          style: GoogleFonts.poppins(
            fontSize: 22,
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
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            final isEmergency = action['isEmergency'] == true;

            return GestureDetector(
              onTap: isSOSCooldown && isEmergency
                  ? null
                  : () => _handleQuickAction(action),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isEmergency && isSOSActive
                      // ✅ FIX: Replaced withValues with withOpacity
                      ? Colors.red.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      // ✅ FIX: Replaced withValues with withOpacity
                      color: (action['color'] as Color).withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isEmergency && isSOSActive
                        ? Colors.red
                        // ✅ FIX: Replaced withValues with withOpacity
                        : (action['color'] as Color).withOpacity(0.3),
                    width: isEmergency && isSOSActive ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isEmergency && isSOSActive)
                      AvatarGlow(
                        endRadius: 30,
                        animate: true,
                        glowColor: Colors.red,
                        duration: Duration(milliseconds: 1500),
                        repeat: true,
                        child: _buildActionIcon(action),
                      )
                    else
                      _buildActionIcon(action),
                    SizedBox(height: 8),
                    Text(
                      isEmergency && isSOSCooldown
                          ? 'Sent!'
                          : action['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSOSCooldown && isEmergency
                            ? Colors.green
                            : darkPurple,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isEmergency && isSOSCooldown
                          ? 'Alert sent'
                          : action['subtitle'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSOSCooldown && isEmergency
                            ? Colors.green
                            : action['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionIcon(Map<String, dynamic> action) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ✅ FIX: Replaced withValues with withOpacity
        color: (action['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        action['icon'] as IconData,
        color: action['color'] as Color,
        size: 24,
      ),
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
                // ✅ FIX: Replaced withValues with withOpacity
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
            border: Border.all(
              // ✅ FIX: Replaced withValues with withOpacity
              color: Colors.grey.withOpacity(0.1),
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
                subtitle: 'Your order is on the way',
                time: '10:34 AM',
                isCompleted: deliveryProgress > 0,
                isActive: deliveryProgress > 0 && deliveryProgress < 1.0,
                icon: Icons.local_shipping,
              ),
              _buildTimelineItem(
                title: 'Delivered',
                subtitle: deliveryProgress >= 1.0
                    ? 'Your order has been delivered'
                    : 'Estimated arrival soon',
                time: deliveryProgress >= 1.0 ? 'Completed' : estimatedTime,
                isCompleted: deliveryProgress >= 1.0,
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
      if (isCompleted) return Colors.green;
      if (isActive) return primaryPurple;
      return Colors.grey.shade400;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isActive
                      // ✅ FIX: Replaced withValues with withOpacity
                      ? getColor().withOpacity(0.1)
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: getColor(),
                    width: 2,
                  ),
                ),
                child: isActive
                    ? Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(getColor()),
                  ),
                )
                    : Icon(
                  isCompleted ? Icons.check : icon,
                  color: getColor(),
                  size: 20,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        // ✅ FIX: Replaced withValues with withOpacity
                        ? Colors.green.withOpacity(0.3)
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                              // ✅ FIX: Replaced withValues with withOpacity
                              ? getColor().withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          time,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isCompleted || isActive
                                ? getColor()
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

  // Action Handlers
  void _handleQuickAction(Map<String, dynamic> action) {
    if (action['isEmergency'] == true) {
      _showSOSConfirmDialog();
    } else if (action['phoneNumber'] != null) {
      EmergencyService.makeEmergencyCall(action['phoneNumber'] as String);
      _showCallingDialog(action['phoneNumber'] as String, action['title'] as String);
    }
  }

  void _showCallingDialog(String number, String service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone, color: Colors.green),
            SizedBox(width: 8),
            Text('Emergency Call'),
          ],
        ),
        content: Text('Calling $service ($number)...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSOSConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Emergency SOS',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will send an emergency alert with your location to:',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 12),
            ...emergencyContacts.map((contact) =>
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        '${contact.name} (${contact.relationship})',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ),
            ).toList(),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ✅ FIX: Replaced withValues with withOpacity
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                // ✅ FIX: Replaced withValues with withOpacity
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only use in real emergencies',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSendSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Send SOS',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendSOS() async {
    setState(() {
      isSOSActive = true;
    });

    // Show loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text(
              'Sending emergency SOS...',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Send the SOS using existing location data
    SOSResult result = await _sendEmergencySMS();

    setState(() {
      isSOSActive = false;
      isSOSCooldown = result.success;
    });

    // Reset cooldown after 10 seconds
    if (result.success) {
      Timer(Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            isSOSCooldown = false;
          });
        }
      });
    }

    // Show result
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.success ? Icons.check_circle : Icons.error,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result.success ? 'SOS Alert Sent!' : 'SOS Failed',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              if (result.sentTo.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  'Sent to: ${result.sentTo.join(', ')}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
              if (result.locationIncluded) ...[
                SizedBox(height: 4),
                Text(
                  '📍 Location included',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
            ],
          ),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: result.success ? SnackBarAction(
            label: 'View Contacts',
            textColor: Colors.white,
            onPressed: () => _showEmergencyContactsDialog(),
          ) : null,
        ),
      );
    }
  }

  void _handleCallDelivery() {
    EmergencyService.makeEmergencyCall('+919876543210');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.call, color: Colors.green),
            SizedBox(width: 8),
            Text('Call Delivery Partner'),
          ],
        ),
        content: Text('Calling Rajesh (+91 98765 43210)...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Contacts Alerted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: emergencyContacts.map((contact) =>
              ListTile(
                leading: CircleAvatar(
                  // ✅ FIX: Replaced withValues with withOpacity
                  backgroundColor: Colors.green.withOpacity(0.2),
                  child: Icon(Icons.check, color: Colors.green),
                ),
                title: Text(contact.name),
                subtitle: Text('${contact.relationship} - ${contact.phone}'),
                dense: true,
              ),
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ✅ FIX: Removed the duplicate EmergencyContact and SOSResult classes.
// They are now defined in emergency_services.dart and imported.