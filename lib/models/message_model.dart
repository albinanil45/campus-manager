import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String content;
  final String senderId;
  bool isDeleted;
  final Timestamp createdAt;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    this.isDeleted = false,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      content: map['content'] ?? '',
      senderId: map['senderId'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'senderId': senderId,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
    };
  }
}
