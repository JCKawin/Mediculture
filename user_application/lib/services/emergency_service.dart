// services/emergency_service.dart
import 'package:another_telephony/telephony.dart';  // Changed import
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class EmergencyService {
  static final Telephony telephony = Telephony.instance;
  static final Location location = Location();

  // Emergency contacts (in real app, get from user profile/database)
  static List<EmergencyContact> emergencyContacts = [
    EmergencyContact(name: 'Mom', phone: '+919150526725', relationship: 'Rescuer'),
    // EmergencyContact(name: 'Dad', phone: '+918765432109', relationship: 'Father'),
    // EmergencyContact(name: 'Spouse', phone: '+917654321098', relationship: 'Partner'),
    // EmergencyContact(name: 'Doctor', phone: '+916543210987', relationship: 'Family Doctor'),
  ];

  // Medical information (in real app, get from user profile)
  static Map<String, dynamic> userMedicalInfo = {
    'name': 'John Doe',
    'age': '32',
    'bloodGroup': 'O+',
    'allergies': 'Peanuts, Shellfish',
    'medications': 'Blood pressure medication',
    'conditions': 'Hypertension',
    'emergencyId': 'MED123456',
  };

  static Future<bool> requestSMSPermissions() async {
    try {
      // Request SMS permission using another_telephony package
      bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
      return permissionsGranted ?? false;
    } catch (e) {
      print('Error requesting SMS permissions: $e');
      return false;
    }
  }

  static Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return null;
      }

      // Check location permission using location package only
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return null;
      }

      return await location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static String formatLocationForSMS(LocationData locationData) {
    return 'https://www.google.com/maps/search/?api=1&query=${locationData.latitude},${locationData.longitude}';
  }

  static String generateEmergencyMessage(LocationData? locationData) {
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
      message += '• Map Link: ${formatLocationForSMS(locationData)}\n';
      message += '• Accuracy: ±${locationData.accuracy?.toStringAsFixed(0)}m\n\n';
    } else {
      message += 'LOCATION: Unable to get current location\n\n';
    }
    
    message += 'Please contact emergency services immediately!\n';
    message += 'Time: ${DateTime.now().toLocal().toString().substring(0, 19)}';
    
    return message;
  }

  // Method to send SMS using existing location data (from TrackingScreen)
  static Future<SOSResult> sendEmergencySOSWithLocation(LocationData? locationData) async {
    try {
      // 1. Check SMS permissions
      bool hasPermission = await requestSMSPermissions();
      if (!hasPermission) {
        return SOSResult(
          success: false,
          message: 'SMS permissions denied',
          sentTo: [],
        );
      }

      // 2. Generate emergency message with provided location
      String emergencyMessage = generateEmergencyMessage(locationData);
      
      // 3. Send SMS to all emergency contacts
      List<String> sentTo = [];
      List<String> failedTo = [];
      
      for (EmergencyContact contact in emergencyContacts) {
        try {
          await telephony.sendSms(
            to: contact.phone,
            message: emergencyMessage,
          );
          sentTo.add('${contact.name} (${contact.relationship})');
          
          // Small delay between messages to avoid rate limiting
          await Future.delayed(Duration(milliseconds: 500));
          
        } catch (e) {
          print('Failed to send SMS to ${contact.name}: $e');
          failedTo.add('${contact.name} (${contact.relationship})');
        }
      }
      
      bool success = sentTo.isNotEmpty;
      String resultMessage = '';
      
      if (success) {
        resultMessage = 'SOS sent to ${sentTo.length} contact${sentTo.length > 1 ? 's' : ''}';
        if (failedTo.isNotEmpty) {
          resultMessage += '\nFailed to reach ${failedTo.length} contact${failedTo.length > 1 ? 's' : ''}';
        }
      } else {
        resultMessage = 'Failed to send SOS to any contacts';
      }
      
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

  // Fallback method that gets location if not provided
  static Future<SOSResult> sendEmergencySMS() async {
    try {
      // Get fresh location if not provided
      LocationData? locationData = await getCurrentLocation();
      return await sendEmergencySOSWithLocation(locationData);
    } catch (e) {
      print('Error sending emergency SMS: $e');
      return SOSResult(
        success: false,
        message: 'Failed to send SOS: ${e.toString()}',
        sentTo: [],
      );
    }
  }

  // Method to send SMS to a single contact (for testing)
  static Future<bool> sendSingleEmergencySMS(EmergencyContact contact) async {
    try {
      // Check permissions first
      bool hasPermission = await requestSMSPermissions();
      if (!hasPermission) return false;

      LocationData? locationData = await getCurrentLocation();
      String emergencyMessage = generateEmergencyMessage(locationData);
      
      await telephony.sendSms(
        to: contact.phone,
        message: emergencyMessage,
      );
      
      return true;
    } catch (e) {
      print('Error sending single SMS: $e');
      return false;
    }
  }

  // Emergency calling functionality
  static Future<bool> makeEmergencyCall(String number) async {
    try {
      final Uri callLaunchUri = Uri(
        scheme: 'tel',
        path: number,
      );
      
      if (await canLaunchUrl(callLaunchUri)) {
        await launchUrl(callLaunchUri);
        return true;
      }
      return false;
    } catch (e) {
      print('Error making emergency call: $e');
      return false;
    }
  }
}

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
