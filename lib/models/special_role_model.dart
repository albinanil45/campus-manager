enum SpecialRole {
  announcementManager,
  superAdmin,
  suggestionManager,
  discussionRoomManager,
}

class SpecialRoleModel {
  final String adminId;
  final SpecialRole specialRole;
  final String assignedBy;

  SpecialRoleModel({
    required this.adminId,
    required this.specialRole,
    required this.assignedBy,
  });

  // Convert Firestore document to SpecialRoleModel
  factory SpecialRoleModel.fromMap(Map<String, dynamic> map) {
    return SpecialRoleModel(
      adminId: map['adminId'] as String,
      specialRole: SpecialRole.values.firstWhere(
        (e) => e.toString() == 'SpecialRole.${map['specialRole']}',
      ),
      assignedBy: map['assignedBy'] as String,
    );
  }

  // Convert SpecialRoleModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'specialRole': specialRole.toString().split('.').last, // Store as String
      'assignedBy': assignedBy,
    };
  }
}
