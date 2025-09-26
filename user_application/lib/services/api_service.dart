import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  // Replace with your laptop's actual IP address
  static const String laptopIP = '192.168.1.100'; // ← Change this to your laptop's IP
  static const String port = '3000';
  
  // Dynamic base URL based on platform
  static const String baseUrl = 'http://172.16.46.167:3000/api';
  
  // Alternative: Simple method for testing - always use laptop IP
  // static const String baseUrl = 'http://192.168.1.100:3000/api'; // ← Replace with your IP
  
  static Future<String?> _getAuthToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  static Future<Map<String, String>> _getHeaders() async {
    String? token = await _getAuthToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Get current user's Firebase UID
  static String? get currentUserUID {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // User Profile Methods
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      String? firebaseUid = currentUserUID;
      if (firebaseUid == null) {
        print('No authenticated user found');
        return null;
      }

      print('Fetching profile for user: $firebaseUid');
      print('API URL: $baseUrl/users/profile?firebaseUid=$firebaseUid');

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile?firebaseUid=$firebaseUid'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: 10));

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        print('User profile not found');
        return null;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      print('Updating profile with data: $userData');
      print('API URL: $baseUrl/users/profile');

      final response = await http.post(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(),
        body: json.encode(userData),
      ).timeout(Duration(seconds: 10));

      print('Update profile response status: ${response.statusCode}');
      print('Update profile response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Medicine Methods
  static Future<Map<String, dynamic>?> getMedicines({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    try {
      String queryParams = '?page=$page&limit=$limit';
      if (category != null) queryParams += '&category=$category';
      if (search != null) queryParams += '&search=$search';

      print('Fetching medicines from: $baseUrl/medicines$queryParams');

      final response = await http.get(
        Uri.parse('$baseUrl/medicines$queryParams'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: 10));

      print('Medicines response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting medicines: $e');
      return null;
    }
  }

  // Get medicine categories
  static Future<List<String>?> getMedicineCategories() async {
    try {
      print('Fetching categories from: $baseUrl/medicines/categories/list');

      final response = await http.get(
        Uri.parse('$baseUrl/medicines/categories/list'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      print('Categories response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<String>();
      }
      return null;
    } catch (e) {
      print('Error getting medicine categories: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMedicineById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicines/$id'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting medicine: $e');
      return null;
    }
  }

  // Appointment Methods
  static Future<bool> bookAppointment(Map<String, dynamic> appointmentData) async {
    try {
      String? firebaseUid = currentUserUID;
      if (firebaseUid == null) return false;

      appointmentData['userId'] = firebaseUid;

      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: await _getHeaders(),
        body: json.encode(appointmentData),
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 201;
    } catch (e) {
      print('Error booking appointment: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getUserAppointments() async {
    try {
      String? firebaseUid = currentUserUID;
      if (firebaseUid == null) return null;

      print('Fetching appointments from: $baseUrl/appointments?firebaseUid=$firebaseUid');

      final response = await http.get(
        Uri.parse('$baseUrl/appointments?firebaseUid=$firebaseUid'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: 10));

      print('Appointments response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['appointments'];
      }
      return null;
    } catch (e) {
      print('Error getting appointments: $e');
      return null;
    }
  }

  // Update appointment status
  static Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/appointments/$appointmentId/status'),
        headers: await _getHeaders(),
        body: json.encode({'status': status}),
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  // Community Methods
  static Future<List<dynamic>?> getCommunityPosts({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    try {
      String queryParams = '?page=$page&limit=$limit';
      if (category != null) queryParams += '&category=$category';

      final response = await http.get(
        Uri.parse('$baseUrl/community$queryParams'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['posts'];
      }
      return null;
    } catch (e) {
      print('Error getting community posts: $e');
      return null;
    }
  }

  static Future<bool> createCommunityPost(Map<String, dynamic> postData) async {
    try {
      String? firebaseUid = currentUserUID;
      if (firebaseUid == null) return false;

      postData['userId'] = firebaseUid;

      final response = await http.post(
        Uri.parse('$baseUrl/community'),
        headers: await _getHeaders(),
        body: json.encode(postData),
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating community post: $e');
      return false;
    }
  }

  // Health check method
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: $baseUrl/test');
      
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      print('Connection test status: ${response.statusCode}');
      print('Connection test response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
