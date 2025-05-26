import 'package:campus_manager/models/discussion_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionRoomService {
  final CollectionReference _discussionRoomRef =
      FirebaseFirestore.instance.collection('discussion_rooms');

  /// Add a new discussion room
  Future<void> createDiscussionRoom(DiscussionRoomModel room) async {
    try {
      final docRef = _discussionRoomRef.doc();
      await docRef.set(room.toMap());
    } catch (e) {
      print('Error creating discussion room: $e');
      rethrow;
    }
  }

  /// Stream all discussion rooms
  Stream<List<DiscussionRoomModel>> getDiscussionRooms() {
    return _discussionRoomRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DiscussionRoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
