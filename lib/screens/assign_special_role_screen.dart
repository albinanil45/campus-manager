import 'dart:async';

import 'package:campus_manager/firebase/admin_service/admin_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/special_role_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';

class AssignSpecialRoleScreen extends StatefulWidget {
  final UserService userService;
  final AdminService adminService;
  final UserModel userModel;
  const AssignSpecialRoleScreen(
      {super.key,
      required this.userService,
      required this.adminService,
      required this.userModel});

  @override
  State<AssignSpecialRoleScreen> createState() =>
      _AssignSpecialRoleScreenState();
}

class _AssignSpecialRoleScreenState extends State<AssignSpecialRoleScreen> {
  List<UserModel> admins = [];
  List<SpecialRoleModel> specialRoleModels = [];

  StreamSubscription? specialRolesSubscription;

  bool isAdminsLoading = false;
  bool isSpecialRolesLoading = false;

  Future<void> _fetchAdmins() async {
    setState(() {
      isAdminsLoading = true;
    });

    final fetchedAdmins = await widget.userService.getAllAdmins();

    setState(() {
      admins = fetchedAdmins;
      isAdminsLoading = false;
    });
  }

  Future<void> _removeRole(String adminId) async {
    await widget.adminService.removeSpecialRole(adminId);
  }

  Future<void> _assignRole(String adminId) async {
    final role = await _showSelectRoleDialog(context);
    if (role != null) {
      final specialRoleModel = SpecialRoleModel(
        adminId: adminId,
        specialRole: role,
        assignedBy: widget.userModel.id,
      );
      await widget.adminService.saveAdminSpecialRole(specialRoleModel);
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchAdmins();
    specialRolesSubscription =
        widget.adminService.streamAllSpecialRoles().listen(
      (specialRoles) {
        setState(
          () {
            specialRoleModels = specialRoles;
          },
        );
      },
    );
  }

  @override
  void dispose() {
    specialRolesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 550,
                    minHeight: constraints.maxHeight,
                  ),
                  child: _buildAdminsList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      foregroundColor: whiteColor,
      title: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double horizontalMargin = (screenWidth - 690) / 2;
          double leftPadding = screenWidth > 690 ? horizontalMargin + 14 : 14;

          return Padding(
            padding: EdgeInsets.only(left: leftPadding),
            child: const Text(
              'Assign special role',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildAdminsList() {
    if (isAdminsLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (admins.isEmpty) {
      return Center(
        child: Text('No admins found'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: admins.length,
      itemBuilder: (context, index) {
        final admin = admins[index];
        return _buildAdminTile(admin);
      },
    );
  }

  Widget _buildAdminTile(UserModel admin) {
    SpecialRoleModel? specialRole;
    try {
      specialRole = specialRoleModels.firstWhere(
        (sr) => sr.adminId == admin.id,
      );
    } catch (e) {
      specialRole = null;
    }

    return Card(
      color: whiteColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
          child: Icon(Icons.person),
        ),
        title: Text(
          admin.name,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              admin.email,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: specialRole != null
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.transparent, // transparent for "no role"
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: specialRole != null ? Colors.blue : Colors.grey,
                ),
              ),
              child: Text(
                specialRole != null
                    ? specialRole.specialRole.readable
                    : 'No roles assigned',
                style: TextStyle(
                  color: specialRole != null ? Colors.blue : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: admin.id != widget.userModel.id
            ? specialRole != null
                ? IconButton(
                    onPressed: () => _removeRole(specialRole!.adminId),
                    icon: Icon(Icons.remove),
                  )
                : IconButton(
                    onPressed: () => _assignRole(admin.id),
                    icon: Icon(Icons.add),
                  )
            : SizedBox(),
      ),
    );
  }

  Future<SpecialRole?> _showSelectRoleDialog(BuildContext context) async {
    SpecialRole? selectedRole = SpecialRole.announcementManager; // default

    return showDialog<SpecialRole>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Select Role",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: SpecialRole.values.map((role) {
                  return RadioListTile<SpecialRole>(
                    title: Text(role.readable),
                    value: role,
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null), // cancel
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, selectedRole), // confirm
                  child: const Text(
                    "Confirm",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                      foregroundColor: whiteColor, minimumSize: Size(120, 40)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
