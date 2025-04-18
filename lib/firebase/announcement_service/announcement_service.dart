import 'package:campus_manager/models/announcement_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementService {
  Future<void> storeAnnouncement(AnnouncementModel announcement) async {
    CollectionReference announcements =
        FirebaseFirestore.instance.collection('announcements');

    // Add a new announcement with auto-generated ID
    await announcements.add(announcement.toMap());
  }

  Stream<List<AnnouncementModel>> getActiveAnnouncementsStream() {
    return FirebaseFirestore.instance
        .collection('announcements')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        return AnnouncementModel.fromDocumentSnapshot(doc);
      }).toList();
    });
  }
}
