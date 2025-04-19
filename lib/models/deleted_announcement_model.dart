import 'package:cloud_firestore/cloud_firestore.dart';

class DeletedAnnouncementModel {
  final String announcementId;
  final String deletedBy;
  final Timestamp deletedAt;

  DeletedAnnouncementModel({
    required this.announcementId,
    required this.deletedBy,
    required this.deletedAt,
  });

  factory DeletedAnnouncementModel.fromMap(Map<String, dynamic> map) {
    return DeletedAnnouncementModel(
      announcementId: map['announcementId'] ?? '',
      deletedBy: map['deletedBy'] ?? '',
      deletedAt: map['deletedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt,
    };
  }
}
