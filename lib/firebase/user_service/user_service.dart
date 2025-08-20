import 'package:campus_manager/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  Future<bool> saveUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toMap());

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Firestore collection name
          .doc(uid) // Get user by UID
          .get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, uid);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getPendingUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userStatus', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<UserModel>> getAllAdmins() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'admin')
          .get();

      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
