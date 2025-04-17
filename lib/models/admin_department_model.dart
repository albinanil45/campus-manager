class AdminDepartmentModel {
  final String adminId;
  final String department;

  AdminDepartmentModel({
    required this.adminId,
    required this.department,
  });

  // Convert Firestore document to AdminDepartmentModel
  factory AdminDepartmentModel.fromMap(Map<String, dynamic> map) {
    return AdminDepartmentModel(
      adminId: map['adminId'] as String,
      department: map['department'] as String,
    );
  }

  // Convert AdminDepartmentModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'department': department,
    };
  }
}
