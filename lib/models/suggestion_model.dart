import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestionModel {
  final String? id;
  final String studentId;
  final String content;
  final SuggestionCategories category;
  bool isReviewed;
  bool isDeleted;
  final bool isPublic;
  String? reviewedBy;
  String? feedback;
  final Timestamp createdAt;

  SuggestionModel({
    required this.id,
    required this.studentId,
    required this.content,
    required this.category,
    required this.isPublic,
    required this.reviewedBy,
    required this.feedback,
    required this.isDeleted,
    required this.isReviewed,
    required this.createdAt,
  });

  factory SuggestionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SuggestionModel(
      id: id,
      studentId: map['studentId'] as String,
      content: map['content'] as String,
      category: SuggestionCategories.values.firstWhere(
        (e) => e.toString() == 'SuggestionCategories.${map['category']}',
      ),
      isPublic: map['isPublic'] as bool,
      reviewedBy: map['reviewedBy'] as String?,
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
      'category': category.name,
      'isPublic': isPublic,
      'reviewedBy': reviewedBy,
      'feedback': feedback,
      'isDeleted': isDeleted,
      'isReviewed': isReviewed,
      'createdAt': createdAt,
    };
  }
}

enum SuggestionCategories {
  teachingImprovement,
  facilitiesImprovement,
  administration,
  eventsAndActivities,
  technologicalImprovement,
  others
}
