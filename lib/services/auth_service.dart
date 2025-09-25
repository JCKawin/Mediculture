// In services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create user model from Firebase User
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL ?? '',
    ) : null;
  }

  // Sign in with email and password - UPDATED
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        return _userFromFirebaseUser(user);
      }
      return null;
      
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'wrong-password':
          throw Exception('Wrong password provided.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Try again later.');
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection.');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Register with email and password - UPDATED
  Future<UserModel?> registerWithEmailAndPassword(
    String email, 
    String password, 
    String fullName,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(fullName);
        
        // Create user document in Firestore
        await _createUserDocument(user, fullName);
        
        return _userFromFirebaseUser(user);
      }
      return null;
      
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password provided is too weak.');
        case 'email-already-in-use':
          throw Exception('An account already exists with this email.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection.');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      print('Registration error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String fullName) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': fullName,
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
      // Don't throw here as user registration was successful
    }
  }

  // Sign out - UPDATED
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  // Reset password - UPDATED
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        default:
          throw Exception('Failed to send reset email: ${e.message}');
      }
    } catch (e) {
      print('Reset password error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Get user data from Firestore - UPDATED
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }
}
