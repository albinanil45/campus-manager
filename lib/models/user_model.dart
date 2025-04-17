import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { student, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final Timestamp createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    
    required this.createdAt,
  });

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      userType: UserType.values.firstWhere(
          (e) => e.toString() == 'UserType.${map['userType']}'),
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  // Convert UserModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType.toString().split('.').last, // Store enum as string
      'createdAt': createdAt,
    };
  }
}
