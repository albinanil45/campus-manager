import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String? id;
  final String studentId;
  final String content;
  bool isReviewed;
  bool isDeleted;
  String? feedback;
  final Timestamp createdAt;

  ComplaintModel({
    required this.id,
    required this.studentId,
    required this.content,
    required this.feedback,
    required this.isDeleted,
    required this.isReviewed,
    required this.createdAt,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ComplaintModel(
      id: id,
      studentId: map['studentId'] as String,
      content: map['content'] as String,
      feedback: map['feedback'] as String?,
      isDeleted: map['isDeleted'] as bool,
      isReviewed: map['isReviewed'] as bool,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'content': content,
      'feedback': feedback,
      'isDeleted': isDeleted,
      'isReviewed': isReviewed,
      'createdAt': createdAt,
    };
  }
}
