import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String baseUrl = 'http://your-backend-url.com/api'; // Update with your deployed URL
  // For local development: 'http://10.0.2.2:3000/api' (Android emulator)
  // For local development: 'http://localhost:3000/api' (iOS simulator)
  
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

  // User Profile Methods
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(),
        body: json.encode(userData),
      );

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

      final response = await http.get(
        Uri.parse('$baseUrl/medicines$queryParams'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting medicines: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMedicineById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicines/$id'),
        headers: await _getHeaders(),
      );

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
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: await _getHeaders(),
        body: json.encode(appointmentData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error booking appointment: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getUserAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments'),
        headers: await _getHeaders(),
      );

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
      );

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
      final response = await http.post(
        Uri.parse('$baseUrl/community'),
        headers: await _getHeaders(),
        body: json.encode(postData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating community post: $e');
      return false;
    }
  }
}
