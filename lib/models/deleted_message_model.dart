import 'package:cloud_firestore/cloud_firestore.dart';

class DeletedMessageModel {
  final String messageId;
  final String deletedBy;
  final Timestamp deletedAt;

  DeletedMessageModel({
    required this.messageId,
    required this.deletedBy,
    required this.deletedAt,
  });

  factory DeletedMessageModel.fromMap(Map<String, dynamic> map) {
    return DeletedMessageModel(
      messageId: map['messageId'] ?? '',
      deletedBy: map['deletedBy'] ?? '',
      deletedAt: map['deletedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt,
    };
  }
}
