import 'package:campus_manager/models/deleted_message_model.dart';
import 'package:campus_manager/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save a message to Firestore (assumes message.id is set)
  Future<void> saveMessage({
    required String discussionRoomId,
    required MessageModel message,
  }) async {
    final docRef = _firestore
        .collection('discussion_rooms')
        .doc(discussionRoomId)
        .collection('messages')
        .doc(); // generate random ID

    final messageWithId = MessageModel(
      id: docRef.id,
      content: message.content,
      senderId: message.senderId,
      isDeleted: message.isDeleted,
      createdAt: message.createdAt,
    );

    await docRef.set(messageWithId.toMap());
  }

  /// Get a stream of messages for a chat room
  Stream<List<MessageModel>> getMessages(String discussionRoomId) {
    return _firestore
        .collection('discussion_rooms')
        .doc(discussionRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> saveDeletedMessage({
    required String roomId,
    required DeletedMessageModel message,
  }) async {
    await _firestore
        .collection('discussion_rooms')
        .doc(roomId)
        .collection('deleted_messages')
        .doc(message.messageId)
        .set(message.toMap());
  }

  /// Stream of all deleted messages for a specific room
  Stream<List<DeletedMessageModel>> getDeletedMessagesStream(String roomId) {
    return _firestore
        .collection('discussion_rooms')
        .doc(roomId)
        .collection('deleted_messages')
        .orderBy('deletedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DeletedMessageModel.fromMap(doc.data());
      }).toList();
    });
  }
}
