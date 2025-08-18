import 'package:campus_manager/firebase/admin_service/admin_service.dart';
import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/firebase/complaint_service/complaint_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/models/special_role_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/screens/assign_special_role_screen.dart';
import 'package:campus_manager/screens/complaint_list_screen.dart';
import 'package:campus_manager/screens/post_complaint_screen.dart';
import 'package:campus_manager/screens/student_or_admin_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomeDrawer extends StatelessWidget {
  final InstitutionModel institutionModel;
  final UserModel user;
  final SpecialRoleModel? specialRoleModel;
  final Authentication authentication;

  const HomeDrawer({
    super.key,
    required this.institutionModel,
    required this.user,
    required this.authentication,
    this.specialRoleModel,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: whiteColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campus Manager',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  institutionModel.name,
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: whiteColor.withAlpha(50),
                      radius: 28,
                      child: const Icon(
                        Icons.person,
                        color: whiteColor,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.userType == UserType.student
                                ? 'Student'
                                : 'Admin',
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: primaryColor,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: blackColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftJoined,
                  childCurrent: this,
                  child: StudentOrAdminScreen(institution: institutionModel),
                ),
              );
              authentication.logoutUser();
            },
          ),
          if (user.userType == UserType.admin &&
              (specialRoleModel != null &&
                  specialRoleModel!.specialRole == SpecialRole.superAdmin))
            ListTile(
              leading: const Icon(
                Icons.report_problem_outlined,
                color: primaryColor,
              ),
              title: const Text(
                'View Complaints',
                style: TextStyle(
                  color: blackColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeftJoined,
                    childCurrent: this,
                    child: ComplaintListScreen(
                      user: user,
                      specialRoleModel: specialRoleModel,
                      userService: UserService(),
                      complaintService: ComplaintService(),
                    ),
                  ),
                );
              },
            ),
          if (user.userType == UserType.student)
            ListTile(
              leading: const Icon(
                Icons.report_problem_outlined,
                color: primaryColor,
              ),
              title: const Text(
                'Post Complaint',
                style: TextStyle(
                  color: blackColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeftJoined,
                    childCurrent: this,
                    child: PostComplaintScreen(
                      user: user,
                      complaintService: ComplaintService(),
                    ),
                  ),
                );
              },
            ),
          if (user.userType == UserType.admin &&
              (specialRoleModel != null &&
                  specialRoleModel!.specialRole == SpecialRole.superAdmin))
            ListTile(
              leading: const Icon(
                Icons.supervised_user_circle_sharp,
                color: primaryColor,
              ),
              title: const Text(
                'Assign special roles',
                style: TextStyle(
                  color: blackColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeftJoined,
                    childCurrent: this,
                    child: AssignSpecialRoleScreen(
                      userService: UserService(),
                      adminService: AdminService(),
                      userModel: user,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
