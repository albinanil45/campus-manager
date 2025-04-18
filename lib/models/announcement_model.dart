import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String? id;
  final String title;
  final String content;
  final Timestamp createdAt;
  final bool isDeleted;
  final String createdBy;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isDeleted,
    required this.createdBy,
  });

  // Convert Firestore document data to model
  factory AnnouncementModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isDeleted: map['isDeleted'] ?? false,
      createdBy: map['createdBy'] ?? '',
    );
  }

  // Create from DocumentSnapshot
  factory AnnouncementModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
  }

  // Convert model to Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
      'createdBy': createdBy,
    };
  }
}
