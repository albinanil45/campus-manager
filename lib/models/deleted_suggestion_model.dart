import 'package:cloud_firestore/cloud_firestore.dart';

class DeletedSuggestionModel {
  final String suggestionId;
  final String deletedBy;
  final Timestamp deletedAt;

  DeletedSuggestionModel({
    required this.suggestionId,
    required this.deletedBy,
    required this.deletedAt,
  });

  factory DeletedSuggestionModel.fromMap(Map<String, dynamic> map) {
    return DeletedSuggestionModel(
      suggestionId: map['suggestionId'] ?? '',
      deletedBy: map['deletedBy'] ?? '',
      deletedAt: map['deletedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'announcementId': suggestionId,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt,
    };
  }
}
