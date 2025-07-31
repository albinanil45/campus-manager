import 'package:campus_manager/models/institution_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstitutionService {
  Future<InstitutionModel?> fetchInstitutionDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('institutions')
          .doc('casadoor')
          .get();

      if (doc.exists && doc.data() != null) {
        return InstitutionModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
