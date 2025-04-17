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
      print('Error saving student course data: $e');
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
        print('No student course data found for ID: $studentId');
        return null;
      }
    } catch (e) {
      print('Error retrieving student course data: $e');
      return null;
    }
  }
}
