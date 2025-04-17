class StudentCourseModel {
  final String studentId;
  final String course;
  final String semester;

  StudentCourseModel({
    required this.studentId,
    required this.course,
    required this.semester,
  });

  // Convert Firestore document to StudentCourseModel
  factory StudentCourseModel.fromMap(Map<String, dynamic> map) {
    return StudentCourseModel(
      studentId: map['studentId'] as String,
      course: map['course'] as String,
      semester: map['semester'] as String,
    );
  }

  // Convert StudentCourseModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'course': course,
      'semester': semester,
    };
  }
}
