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
}
