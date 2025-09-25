// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      return _userFromFirebaseUser(result.user);
      
    } on FirebaseAuthException catch (e) {
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
        case 'operation-not-allowed':
          throw Exception('Email/password sign-in is not enabled');
        default:
          throw Exception('Login failed. Please try again');
      }
    } catch (e) {
      print('Sign in error: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Login failed. Please check your credentials and try again');
    }
  }

  // FIXED Register with email and password - handles the type casting issue
  Future<UserModel?> registerWithEmailAndPassword(
    String email, 
    String password, 
    String fullName,
  ) async {
    print('=== REGISTRATION START ===');
    print('Email: $email');
    print('Password length: ${password.length}');
    print('Full name: $fullName');
    
    try {
      // Create user - this is where the PigeonUserDetails error occurs
      print('Creating Firebase Auth user...');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      print('User created successfully: ${result.user?.uid}');
      
      if (result.user != null) {
        User user = result.user!;
        print('User object retrieved: ${user.uid}');
        
        // Update display name with error handling
        try {
          print('Updating display name...');
          await user.updateDisplayName(fullName);
          print('Display name updated successfully');
        } catch (displayError) {
          print('Display name update failed (continuing anyway): $displayError');
          // Don't fail registration for this
        }
        
        // Create and return UserModel
        UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email ?? email,
          displayName: fullName, // Use the provided name regardless
          photoURL: user.photoURL ?? '',
        );
        
        print('UserModel created: ${userModel.uid}');
        print('=== REGISTRATION SUCCESS ===');
        return userModel;
        
      } else {
        throw Exception('User creation failed - no user data returned');
      }
      
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password should be at least 6 characters long');
        case 'email-already-in-use':
          throw Exception('An account already exists with this email address');
        case 'invalid-email':
          throw Exception('Please enter a valid email address');
        case 'operation-not-allowed':
          throw Exception('Email registration is not enabled. Please contact support');
        case 'network-request-failed':
          throw Exception('Network error. Please check your internet connection');
        default:
          throw Exception('Registration failed: ${e.message ?? 'Please try again'}');
      }
    } catch (e) {
      print('Unexpected registration error: $e');
      print('Error type: ${e.runtimeType}');
      
      // Handle the specific PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print('PigeonUserDetails error detected - trying workaround...');
        
        // Workaround: Check if user was actually created
        try {
          await Future.delayed(Duration(milliseconds: 500)); // Small delay
          User? currentUser = _auth.currentUser;
          
          if (currentUser != null) {
            print('User was created successfully despite error: ${currentUser.uid}');
            
            // Try to update display name
            try {
              await currentUser.updateDisplayName(fullName);
            } catch (_) {
              print('Display name update failed in workaround');
            }
            
            return UserModel(
              uid: currentUser.uid,
              email: currentUser.email ?? email,
              displayName: fullName,
              photoURL: currentUser.photoURL ?? '',
            );
          }
        } catch (workaroundError) {
          print('Workaround failed: $workaroundError');
        }
        
        throw Exception('Account creation completed but there was a technical issue. Please try logging in');
      }
      
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Registration failed: ${e.toString()}');
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
      print('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      print('Reset password error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email address');
        case 'invalid-email':
          throw Exception('Please enter a valid email address');
        case 'network-request-failed':
          throw Exception('Network error. Please check your internet connection');
        default:
          throw Exception('Failed to send reset email. Please try again');
      }
    } catch (e) {
      print('Reset password error: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to send reset email. Please try again');
    }
  }

  // Check if user is signed in
  bool get isSignedIn {
    return _auth.currentUser != null;
  }

  // Get current user's display name
  String get currentUserDisplayName {
    return _auth.currentUser?.displayName ?? '';
  }

  // Get current user's email
  String get currentUserEmail {
    return _auth.currentUser?.email ?? '';
  }
}
