// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // FIXED Sign in with PigeonUserDetails error handling
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    print('=== SIGN IN ATTEMPT ===');
    print('Email: $email');
    
    try {
      // Attempt sign in
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      print('Sign in successful: ${result.user?.uid}');
      return _createUserModel(result.user, email);
      
    } catch (e) {
      print('Sign in error: $e');
      
      // Check if it's the PigeonUserDetails error but user is actually signed in
      if (e.toString().contains('PigeonUserDetails') || e.toString().contains('type cast')) {
        print('PigeonUserDetails error detected - checking if sign in actually succeeded...');
        
        // Wait a bit for Firebase to update
        await Future.delayed(Duration(milliseconds: 500));
        
        // Check if user is now signed in
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('SUCCESS: User is actually signed in despite error: ${currentUser.uid}');
          return _createUserModel(currentUser, email);
        }
      }
      
      // Handle Firebase Auth exceptions
      if (e is FirebaseAuthException) {
        _handleFirebaseAuthError(e);
      } else {
        throw Exception('Sign in failed. Please check your credentials and try again');
      }
    }
    
    return null;
  }

  // FIXED Register with PigeonUserDetails error handling
  Future<UserModel?> registerWithEmailAndPassword(
    String email, 
    String password, 
    String fullName,
  ) async {
    print('=== REGISTRATION ATTEMPT ===');
    print('Email: $email');
    print('Name: $fullName');
    
    try {
      // Attempt registration
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      print('Registration successful: ${result.user?.uid}');
      
      // Try to update display name (non-critical)
      if (result.user != null) {
        try {
          await result.user!.updateDisplayName(fullName);
          print('Display name updated');
        } catch (displayError) {
          print('Display name update failed (non-critical): $displayError');
        }
      }
      
      return _createUserModel(result.user, email, fullName);
      
    } catch (e) {
      print('Registration error: $e');
      
      // Check if it's the PigeonUserDetails error but user is actually created
      if (e.toString().contains('PigeonUserDetails') || e.toString().contains('type cast')) {
        print('PigeonUserDetails error detected - checking if registration actually succeeded...');
        
        // Wait a bit for Firebase to update
        await Future.delayed(Duration(milliseconds: 500));
        
        // Check if user is now signed in (meaning registration succeeded)
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('SUCCESS: User was actually created despite error: ${currentUser.uid}');
          
          // Try to update display name
          try {
            await currentUser.updateDisplayName(fullName);
            print('Display name updated in workaround');
          } catch (displayError) {
            print('Display name update failed in workaround: $displayError');
          }
          
          return _createUserModel(currentUser, email, fullName);
        }
      }
      
      // Handle Firebase Auth exceptions
      if (e is FirebaseAuthException) {
        _handleFirebaseAuthError(e);
      } else {
        throw Exception('Registration failed. Please try again');
      }
    }
    
    return null;
  }

  // Helper method to create UserModel
  UserModel? _createUserModel(User? user, String email, [String? displayName]) {
    if (user == null) return null;
    
    return UserModel(
      uid: user.uid,
      email: user.email ?? email,
      displayName: displayName ?? user.displayName ?? '',
      photoURL: user.photoURL ?? '',
    );
  }

  // Handle Firebase Auth errors
  void _handleFirebaseAuthError(FirebaseAuthException e) {
    print('Firebase Auth Error: ${e.code} - ${e.message}');
    
    switch (e.code) {
      case 'user-not-found':
        throw Exception('No account found with this email address');
      case 'wrong-password':
        throw Exception('Incorrect password. Please try again');
      case 'invalid-credential':
        throw Exception('Invalid email or password');
      case 'user-disabled':
        throw Exception('This account has been disabled');
      case 'too-many-requests':
        throw Exception('Too many failed attempts. Please try again later');
      case 'network-request-failed':
        throw Exception('Network error. Please check your internet connection');
      case 'invalid-email':
        throw Exception('Please enter a valid email address');
      case 'email-already-in-use':
        throw Exception('An account already exists with this email address');
      case 'weak-password':
        throw Exception('Password should be at least 6 characters long');
      case 'operation-not-allowed':
        throw Exception('Email authentication is not enabled');
      default:
        throw Exception('Authentication failed: ${e.message ?? 'Please try again'}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Failed to sign out. Please try again');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Failed to send reset email. Please try again');
    }
  }

  // Helper getters
  bool get isSignedIn => _auth.currentUser != null;
  String get currentUserEmail => _auth.currentUser?.email ?? '';
  String get currentUserDisplayName => _auth.currentUser?.displayName ?? '';
  String get currentUserUID => _auth.currentUser?.uid ?? '';
}
