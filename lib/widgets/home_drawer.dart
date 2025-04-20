import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/screens/student_or_admin_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomeDrawer extends StatelessWidget {
  final InstitutionModel institutionModel;
  final UserModel user;
  final Authentication authentication;

  const HomeDrawer({
    super.key,
    required this.institutionModel,
    required this.user,
    required this.authentication,
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
                    fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.userType == UserType.student ? 'Student' : 'Admin',
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
        ],
      ),
    );
  }
}
