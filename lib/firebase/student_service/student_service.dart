import 'package:campus_manager/models/student_course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  Future<bool> saveStudentCourse(StudentCourseModel studentCourse) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('student_course')
          .doc(studentCourse.studentId);

      await docRef.set(studentCourse.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<StudentCourseModel?> getStudentCourse(String studentId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('student_course')
          .doc(studentId);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return StudentCourseModel.fromMap(docSnapshot.data()!);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<StudentCourseModel>> getAllStudentCourses() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('student_courses').get();

      return snapshot.docs.map((doc) {
        return StudentCourseModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> incrementSemesterForStudents(
      String currentSemester) async {
    final collection = FirebaseFirestore.instance.collection('student_course');

    final querySnapshot =
        await collection.where('semester', isEqualTo: currentSemester).get();

    if (querySnapshot.docs.isEmpty) return;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var doc in querySnapshot.docs) {
      final currentSem = int.tryParse(doc['semester'].toString());
      if (currentSem != null) {
        final nextSem = (currentSem + 1).toString();
        batch.update(doc.reference, {'semester': nextSem});
      }
    }

    await batch.commit();
  }

  static Future<void> removeSemester6Students() async {
    final studentCourses =
        FirebaseFirestore.instance.collection('student_course');
    final users = FirebaseFirestore.instance.collection('users');

    final querySnapshot =
        await studentCourses.where('semester', isEqualTo: "6").get();

    if (querySnapshot.docs.isEmpty) return;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var doc in querySnapshot.docs) {
      final studentId = doc['studentId'] as String;
      final userRef = users.doc(studentId);
      batch.update(userRef, {'userStatus': 'removed'});
    }

    await batch.commit();
  }
}
