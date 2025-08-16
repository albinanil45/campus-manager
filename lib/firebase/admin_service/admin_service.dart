import 'package:campus_manager/models/admin_department_model.dart';
import 'package:campus_manager/models/special_role_model.dart';
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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> saveAdminSpecialRole(SpecialRoleModel roleModel) async {
    final docRef = FirebaseFirestore.instance
        .collection('special_roles')
        .doc(roleModel.adminId);

    await docRef.set(roleModel.toMap());
  }

  Future<SpecialRoleModel?> getSpecialRole(String adminId) async {
    final docRef =
        FirebaseFirestore.instance.collection('special_roles').doc(adminId);

    final docSnap = await docRef.get();

    if (docSnap.exists) {
      return SpecialRoleModel.fromMap(docSnap.data()!);
    } else {
      return null;
    }
  }

  Stream<List<SpecialRoleModel>> streamAllSpecialRoles() {
    return FirebaseFirestore.instance
        .collection('special_roles')
        .snapshots()
        .map((querySnap) => querySnap.docs
            .map((doc) => SpecialRoleModel.fromMap(doc.data()))
            .toList());
  }
}
