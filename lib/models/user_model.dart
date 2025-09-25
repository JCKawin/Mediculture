import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final DateTime? createdAt;
  final DateTime? lastSeen;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL = '',
    this.createdAt,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'] ?? '',
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] as Timestamp).toDate()
        : null,
      lastSeen: map['lastSeen'] != null 
        ? (map['lastSeen'] as Timestamp).toDate()
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }
}
