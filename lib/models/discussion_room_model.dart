import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionRoomModel {
  final String id;
  final String roomTitle;
  final String roomDescription;
  final String createdBy;
  final Timestamp createdAt;
  bool isClosed;
  String? outcome;
  final String? closedBy;

  DiscussionRoomModel({
    required this.id,
    required this.roomTitle,
    required this.roomDescription,
    required this.createdBy,
    required this.createdAt,
    this.isClosed = false,
    this.outcome,
    this.closedBy,
  });

  factory DiscussionRoomModel.fromMap(Map<String, dynamic> map, String id) {
    return DiscussionRoomModel(
      id: id,
      roomTitle: map['roomTitle'] ?? '',
      roomDescription: map['roomDescription'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isClosed: map['isClosed'] ?? false,
      outcome: map['outcome'],
      closedBy: map['closedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomTitle': roomTitle,
      'roomDescription': roomDescription,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'isClosed': isClosed,
      'outcome': outcome,
      'closedBy': closedBy,
    };
  }
}
