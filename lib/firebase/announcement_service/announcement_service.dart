import 'package:campus_manager/models/announcement_model.dart';
import 'package:campus_manager/models/deleted_announcement_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementService {
  Future<void> storeAnnouncement(AnnouncementModel announcement) async {
  CollectionReference announcements =
      FirebaseFirestore.instance.collection('announcements');

  if (announcement.id != null) {
    // Use the provided ID
    await announcements.doc(announcement.id).set(announcement.toMap());
  } else {
    // Add with auto-generated ID
    await announcements.add(announcement.toMap());
  }
}


  Stream<List<AnnouncementModel>> getActiveAnnouncementsStream() {
    return FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        return AnnouncementModel.fromDocumentSnapshot(doc);
      }).toList();
    });
  }

  /// Store a deleted announcement
  Future<void> storeDeletedAnnouncement(DeletedAnnouncementModel model) async {
    await FirebaseFirestore.instance
        .collection('deleted_announcements')
        .doc(model.announcementId)
        .set(model.toMap());
  }

  /// Get a deleted announcement by its announcementId
  Future<DeletedAnnouncementModel?> getDeletedAnnouncement(
      String announcementId) async {
    final doc = await FirebaseFirestore.instance
        .collection('deleted_announcements')
        .doc(announcementId)
        .get();

    if (doc.exists && doc.data() != null) {
      return DeletedAnnouncementModel.fromMap(doc.data()!);
    }
    return null;
  }
}
