// services/emergency_services.dart
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

// ✅ FIX: The classes are now defined in one central place.
class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });
}

class SOSResult {
  final bool success;
  final String message;
  final List<String> sentTo;
  final List<String> failedTo;
  final bool locationIncluded;

  SOSResult({
    required this.success,
    required this.message,
    required this.sentTo,
    this.failedTo = const [],
    this.locationIncluded = false,
  });
}

class EmergencyService {
  static final Location _location = Location();

  // Centralized data source for contacts and medical info
  static List<EmergencyContact> emergencyContacts = [
    EmergencyContact(name: 'Mom', phone: '+919150526725', relationship: 'Rescuer'),
    // EmergencyContact(name: 'Dad', phone: '+918765432109', relationship: 'Father'),
    // EmergencyContact(name: 'Spouse', phone: '+917654321098', relationship: 'Partner'),
    // EmergencyContact(name: 'Doctor', phone: '+916543210987', relationship: 'Family Doctor'),
  ];

  static Map<String, dynamic> userMedicalInfo = {
    'name': 'John Doe',
    'age': '32',
    'bloodGroup': 'O+',
    'allergies': 'Peanuts, Shellfish',
    'medications': 'Blood pressure medication',
    'conditions': 'Hypertension',
    'emergencyId': 'MED123456',
  };

  static Future<LocationData?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return null;
      }
      
      return await _location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static String _formatLocationForSMS(LocationData locationData) {
    print("Latitude and Longitude:");
    print(locationData.latitude);
    print(locationData.longitude);

    return 'https://www.google.com/maps/search/?api=1&query=${locationData.latitude},${locationData.longitude}';
  }

  static String _generateEmergencyMessage(LocationData? locationData) {
    String message = '🚨 EMERGENCY ALERT 🚨\n\n';
    message += '${userMedicalInfo['name']} needs immediate help!\n\n';
    message += 'MEDICAL INFO:\n';
    message += '• Age: ${userMedicalInfo['age']}\n';
    message += '• Blood Group: ${userMedicalInfo['bloodGroup']}\n';
    message += '• Allergies: ${userMedicalInfo['allergies']}\n';
    message += '• Medical ID: ${userMedicalInfo['emergencyId']}\n\n';

    if (locationData != null) {
      message += 'LOCATION:\n';
      message += '• Coordinates: ${locationData.latitude?.toStringAsFixed(6)}, ${locationData.longitude?.toStringAsFixed(6)}\n';
      message += '• Map Link: ${_formatLocationForSMS(locationData)}\n';
      message += '• Accuracy: ±${locationData.accuracy?.toStringAsFixed(0)}m\n\n';
    } else {
      message += 'LOCATION: Unable to get current location.\n\n';
    }

    message += 'Please contact emergency services immediately!\n';
    message += 'Time: ${DateTime.now().toLocal().toString().substring(0, 19)}';

    return message;
  }

  // Main method called by the UI
  static Future<SOSResult> sendEmergencySOSWithLocation(LocationData? locationData) async {
    try {
      String emergencyMessage = _generateEmergencyMessage(locationData);
      List<String> sentTo = [];
      List<String> failedTo = [];

      // Combine all phone numbers into a single SMS URI for a better user experience
      String recipients = emergencyContacts.map((c) => c.phone).join(',');

      final Uri smsLaunchUri = Uri(
        scheme: 'sms',
        path: recipients,
        queryParameters: <String, String>{
          'body': Uri.encodeComponent(emergencyMessage),
        },
      );

      if (await canLaunchUrl(smsLaunchUri)) {
        await launchUrl(smsLaunchUri);
        sentTo = emergencyContacts.map((c) => c.name).toList();
      } else {
        failedTo = emergencyContacts.map((c) => c.name).toList();
      }

      bool success = sentTo.isNotEmpty;
      String resultMessage = success
          ? 'SMS app opened for emergency contacts.'
          : 'Failed to open SMS app.';

      return SOSResult(
        success: success,
        message: resultMessage,
        sentTo: sentTo,
        failedTo: failedTo,
        locationIncluded: locationData != null,
      );
    } catch (e) {
      print('Error sending emergency SMS: $e');
      return SOSResult(
        success: false,
        message: 'Failed to send SOS: ${e.toString()}',
        sentTo: [],
      );
    }
  }

  // Fallback method that gets a fresh location if one isn't provided
  static Future<SOSResult> sendEmergencySMS() async {
    LocationData? locationData = await _getCurrentLocation();
    return await sendEmergencySOSWithLocation(locationData);
  }

  // Emergency calling functionality
  static Future<void> makeEmergencyCall(String number) async {
    try {
      final Uri callLaunchUri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(callLaunchUri)) {
        await launchUrl(callLaunchUri);
      } else {
        print('Could not launch emergency call to $number');
      }
    } catch (e) {
      print('Error making emergency call: $e');
    }
  }
}