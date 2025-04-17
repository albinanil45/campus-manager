import 'package:campus_manager/models/admin_department_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  Future<bool> saveAdminDepartment(AdminDepartmentModel adminDepartment) async {
    try {
      await FirebaseFirestore.instance
          .collection('admin_departments')
          .doc(adminDepartment.adminId) // Use adminId as document name
          .set(adminDepartment.toMap()); // Store department data

      return true; // Successfully saved
    } catch (e) {
      print("Error saving admin department: $e");
      return false; // Failed to save
    }
  }

  Future<AdminDepartmentModel?> getAdminDepartment(String adminId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('admin_departments') // Firestore collection name
          .doc(adminId) // Get admin department by adminId
          .get();

      if (doc.exists) {
        return AdminDepartmentModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("Admin department not found");
        return null;
      }
    } catch (e) {
      print("Error fetching admin department: $e");
      return null;
    }
  }
}
