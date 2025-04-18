import 'package:campus_manager/models/announcement_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementService {
  Future<void> storeAnnouncement(AnnouncementModel announcement) async {
    CollectionReference announcements =
        FirebaseFirestore.instance.collection('announcements');

    // Add a new announcement with auto-generated ID
    await announcements.add(announcement.toMap());
  }
}
