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
import 'package:campus_manager/widgets/live_time_ago.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  final Authentication authentication;
  final InstitutionModel institution;
  final UserModel user;
  final AdminDepartmentModel? departmentModel;
  final SpecialRoleModel? specialRoleModel;
  final StudentCourseModel? studentCourseModel;
  final AnnouncementService announcementService;

  const HomeScreen({
    super.key,
    required this.authentication,
    required this.institution,
    required this.user,
    required this.departmentModel,
    required this.studentCourseModel,
    required this.specialRoleModel,
    required this.announcementService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double maxContentWidth = 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        leading: IconButton(
          onPressed: () {
            
          },
          icon: Icon(
            Icons.dehaze_rounded
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600
              ),
            ),
            Text(
              widget.institution.name,
              style: TextStyle(
                fontSize: 13
              ),
            )
          ],
        )
      ),
      body: Stack(
        children: [
          // ================= Header =================
          Column(
            children: [
              Container(
                color: primaryColor,
                height: 260,
                width: double.infinity,
                
              ),
            ],
          ),

          // ================= Announcements =================
          Positioned(
            top: 10,
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
                          height: 430,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // --- Header Row ---
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
                                    if (widget.user.userType == UserType.admin &&
                                        (widget.specialRoleModel?.specialRole == SpecialRole.superAdmin ||
                                         widget.specialRoleModel?.specialRole == SpecialRole.announcementManager))
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType.rightToLeftWithFade,
                                              child: PostAnnouncementScreen(
                                                announcementService: AnnouncementService(),
                                                user: widget.user,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ButtonStyle(
                                          elevation: const WidgetStatePropertyAll(0),
                                          minimumSize: const WidgetStatePropertyAll(Size(40, 25)),
                                          backgroundColor: const WidgetStatePropertyAll(whiteColor),
                                          side: const WidgetStatePropertyAll(
                                            BorderSide(width: 1, color: primaryColor),
                                          ),
                                          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                                            (states) {
                                              if (states.contains(WidgetState.pressed)) {
                                                return primaryColor.withAlpha(25);
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        child: const Text(
                                          'Post',
                                          style: TextStyle(color: primaryColor),
                                        ),
                                      )
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // --- Announcements List ---
                                Expanded(
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: StreamBuilder(
                                      stream: widget.announcementService.getActiveAnnouncementsStream(),
                                      builder: (context, snapshot) {
                                        final isLoading = snapshot.connectionState == ConnectionState.waiting;
                                        final announcements = snapshot.data ?? [];

                                        return Skeletonizer(
                                          enabled: isLoading,
                                          child: ListView.separated(
                                            itemCount: announcements.length > 3 ? 3 : announcements.length,
                                            itemBuilder: (context, index) {
                                              final announcement = announcements[index];

                                              return ListTile(
                                                leading: const Icon(Icons.campaign_outlined, color: primaryColor),
                                                title: Text(
                                                  announcement.title,
                                                  style: const TextStyle(fontSize: 15),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      'By Ancy Jacob', // Replace with actual admin name in future
                                                      style: TextStyle(fontSize: 13),
                                                    ),
                                                    LiveTimeAgo(timestamp: announcement.createdAt),
                                                  ],
                                                ),
                                              );
                                            },
                                            separatorBuilder: (_, __) => const Divider(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                // --- See More Button ---
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
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

          // ================= Discussion Rooms =================
          Positioned(
            top: 460,
            left: 0,
            right: 0,
            child: _buildInfoCard(
              icon: Icons.chat_bubble_outline,
              title: 'Discussion Rooms',
              subtitle: 'Tap to view discussion rooms',
              onTap: () {
                // Navigate or do something
              },
            ),
          ),

          // ================= Suggestions =================
          Positioned(
            top: 550,
            left: 0,
            right: 0,
            child: _buildInfoCard(
              icon: Icons.lightbulb_outline,
              title: 'Suggestions',
              subtitle: 'Tap to view publicly shared suggestions',
              onTap: () {
                // Navigate or do something
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
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
                  leading: Icon(icon, color: primaryColor),
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(subtitle),
                  onTap: onTap,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
