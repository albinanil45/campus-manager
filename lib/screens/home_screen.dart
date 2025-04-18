import 'package:campus_manager/firebase/announcement_service/announcement_service.dart';
import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/models/admin_department_model.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/models/special_role_model.dart';
import 'package:campus_manager/models/student_course_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/screens/post_announcement_screen.dart';
import 'package:campus_manager/screens/student_or_admin_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreen extends StatefulWidget {
  final Authentication authentication;
  final InstitutionModel institution;
  final UserModel user;
  final AdminDepartmentModel? departmentModel;
  final SpecialRoleModel? specialRoleModel;
  final StudentCourseModel? studentCourseModel;
  const HomeScreen({
    super.key,
    required this.authentication,
    required this.institution,
    required this.user,
    required this.departmentModel,
    required this.studentCourseModel,
    required this.specialRoleModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double maxContentWidth = 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background and Header
          Column(
            children: [
              Container(
                color: primaryColor,
                height: 260,
                width: double.infinity,
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: maxContentWidth),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () async {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => StudentOrAdminScreen(
                                      institution: widget.institution,
                                    ),
                                  ),
                                );
                                await widget.authentication.logoutUser();
                              },
                              icon: const Icon(
                                Icons.menu,
                                color: whiteColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 14),
                                Text(
                                  widget.user.name,
                                  style: const TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  widget.institution.name,
                                  style: TextStyle(
                                    color: whiteColor.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Announcements
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 650;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxContentWidth),
                      child: Card(
                        color: whiteColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          height: 360,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 14),
                                    const Text(
                                      'Announcements',
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    widget.user.userType == UserType.admin &&
                                            (widget.specialRoleModel
                                                        ?.specialRole ==
                                                    SpecialRole.superAdmin ||
                                                widget.specialRoleModel
                                                        ?.specialRole ==
                                                    SpecialRole
                                                        .announcementManager)
                                        ? ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType.rightToLeftWithFade,
                                                      child: PostAnnouncementScreen(
                                                        announcementService: AnnouncementService(),
                                                        user: widget.user,
                                                      )));
                                            },
                                            child: const Text(
                                              'Post',
                                              style: TextStyle(
                                                  color: primaryColor),
                                            ),
                                            style: ButtonStyle(
                                              elevation:
                                                  const WidgetStatePropertyAll(
                                                      0),
                                              minimumSize:
                                                  const WidgetStatePropertyAll(
                                                      Size(40, 25)),
                                              backgroundColor:
                                                  const WidgetStatePropertyAll(
                                                      whiteColor),
                                              side: const WidgetStatePropertyAll(
                                                BorderSide(
                                                    width: 1,
                                                    color: primaryColor),
                                              ),
                                              overlayColor: WidgetStateProperty
                                                  .resolveWith<Color?>(
                                                (states) {
                                                  if (states.contains(
                                                      WidgetState.pressed)) {
                                                    return primaryColor.withValues(
                                                        alpha:
                                                            0.1); // subtle tap effect
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: ListView.separated(
                                      itemCount: 3,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading: const Icon(Icons.campaign_outlined,
                                              color: primaryColor),
                                          title: Text(
                                              'This is an announcement ${index + 1}',
                                              style: const TextStyle(fontSize: 15)),
                                          subtitle: const Text('Admin name',
                                              style: TextStyle(fontSize: 13)),
                                          trailing: Text(
                                            'Now',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (_, __) => const Divider(),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        size: 16, color: primaryColor),
                                    label: const Text('See more'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Discussion Rooms
          Positioned(
            top: 480,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 650;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxContentWidth),
                      child: Card(
                        color: whiteColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.chat_bubble_outline,
                              color: primaryColor),
                          title: const Text(
                            'Discussion Rooms',
                            style: TextStyle(
                              color: blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text('Tap to view discussion rooms'),
                          onTap: () {
                            // navigate or do something
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Suggestions
          Positioned(
            top: 570,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 650;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxContentWidth),
                      child: Card(
                        color: whiteColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.lightbulb_outline,
                              color: primaryColor),
                          title: const Text(
                            'Suggestions',
                            style: TextStyle(
                              color: blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle:
                              const Text('Tap to view publicly shared suggestions'),
                          onTap: () {
                            // navigate or do something
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
