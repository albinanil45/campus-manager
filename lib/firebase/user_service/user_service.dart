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
      print("Error saving user: $e");
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
        print("User not found");
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }
}
