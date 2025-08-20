import 'package:campus_manager/models/complaint_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintService {
  final _complaintsCollection =
      FirebaseFirestore.instance.collection('complaints');

  /// Store or update a complaint
  Future<void> storeComplaint(ComplaintModel complaint) async {
    if (complaint.id != null) {
      // Update with provided ID
      await _complaintsCollection.doc(complaint.id).set(complaint.toMap());
    } else {
      // Create with auto-generated ID
      await _complaintsCollection.add(complaint.toMap());
    }
  }

  /// Get all complaints as a real-time stream
  Stream<List<ComplaintModel>> getComplaintsStream() {
    return _complaintsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return ComplaintModel.fromMap(doc.data(), id: doc.id);
            }).toList());
  }

  /// Get a single complaint by its ID
  Future<ComplaintModel?> getComplaintById(String complaintId) async {
    final doc = await _complaintsCollection.doc(complaintId).get();
    if (doc.exists && doc.data() != null) {
      return ComplaintModel.fromMap(doc.data()!, id: doc.id);
    }
    return null;
  }

  Stream<List<ComplaintModel>> getComplaintsByStudentStream(String studentId) {
    return _complaintsCollection
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return ComplaintModel.fromMap(doc.data(), id: doc.id);
            }).toList());
  }
}
