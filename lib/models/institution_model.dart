class InstitutionModel {
  final String id;
  final String name;
  final String phone;
  final String adminPasscode; 
  final List<String> departments;
  final List<String> courses;

  InstitutionModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.adminPasscode,
    required this.departments,
    required this.courses,
  });

  // Convert Firestore document to InstitutionModel
  factory InstitutionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return InstitutionModel(
      id: documentId,
      name: map['name'] as String,
      phone: map['phone'] as String,
      adminPasscode: map['adminPasscode'] as String, 
      departments: List<String>.from(map['departments'] ?? []),
      courses: List<String>.from(map['courses'] ?? []),
    );
  }

  // Convert InstitutionModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'adminPasscode': adminPasscode, // ⚠️ Consider storing hashed version
      'departments': departments,
      'courses': courses,
    };
  }
}
