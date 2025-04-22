import 'package:campus_manager/firebase/announcement_service/announcement_service.dart';
import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/firebase/suggestion_service/suggestion_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/admin_department_model.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/models/special_role_model.dart';
import 'package:campus_manager/models/student_course_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/screens/announcements_list_screen.dart';
import 'package:campus_manager/screens/post_announcement_screen.dart';
import 'package:campus_manager/screens/post_suggestion_screen.dart';
import 'package:campus_manager/screens/suggestions_list_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/widgets/home_drawer.dart';
import 'package:campus_manager/widgets/live_time_ago.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  final Authentication authentication;
  final InstitutionModel institution;
  final UserModel user;
  final UserService userService;
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
    required this.userService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double maxContentWidth = 600;

  Future<List<dynamic>> getDeletedData(
    String uid,
    String announcementId,
    bool isDeleted,
  ) async {
    List<dynamic> list = [];
    final user = await widget.userService.getUser(uid);
    list.add(user);

    if (isDeleted) {
      final deletedData = await widget.announcementService.getDeletedAnnouncement(announcementId);
      final deletedAdmin = await widget.userService.getUser(deletedData!.deletedBy);
      list.add(deletedAdmin);
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: HomeDrawer(
        institutionModel: widget.institution,
        user: widget.user,
        authentication: Authentication(),
      ),
      body: Stack(
        children: [
          _buildHeaderBackground(),
          _buildAnnouncementCard(),
          _buildInfoCardSection(
            top: 460,
            icon: Icons.chat_bubble_outline,
            title: 'Discussion Rooms',
            subtitle: 'Tap to view discussion rooms',
            user: widget.user,
            specialRole: widget.specialRoleModel?.specialRole,
            onTap: () {},
            buttonOnTap: (){
              
            }
          ),
          _buildInfoCardSection(
            top: 550,
            icon: Icons.lightbulb_outline,
            title: 'Suggestions',
            subtitle: 'Tap to view publicly shared suggestions',
            user: widget.user,
            specialRole: widget.specialRoleModel?.specialRole,
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: SuggestionsListScreen(user: widget.user,suggestionService: SuggestionService(),userService: UserService(),specialRole: widget.specialRoleModel?.specialRole,studentService: StudentService(),)
                )
              );
            },
            buttonOnTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: PostSuggestionScreen(
                    user: widget.user,
                    suggestionService: SuggestionService(),
                  )
                )
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      foregroundColor: whiteColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.user.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            widget.institution.name,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Column(
      children: [
        Container(
          color: primaryColor,
          height: 260,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard() {
    return Positioned(
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
                          _buildAnnouncementHeader(),
                          const SizedBox(height: 10),
                          _buildAnnouncementList(),
                          _buildSeeMoreButton(),
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
    );
  }

  Widget _buildAnnouncementHeader() {
    final user = widget.user;
    final specialRole = widget.specialRoleModel?.specialRole;

    return Row(
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
        if (user.userType == UserType.admin &&
            (specialRole == SpecialRole.superAdmin ||
                specialRole == SpecialRole.suggestionManager))
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: PostAnnouncementScreen(
                    announcementService: AnnouncementService(),
                    user: user,
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
                (states) => states.contains(WidgetState.pressed)
                    ? primaryColor.withAlpha(25)
                    : null,
              ),
            ),
            child: const Text(
              'Post',
              style: TextStyle(color: primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildAnnouncementList() {
  return Expanded(
    child: MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: StreamBuilder(
        stream: widget.announcementService.getActiveAnnouncementsStream(),
        builder: (context, snapshot) {
          bool isLoading = snapshot.connectionState == ConnectionState.waiting;
          final announcements = snapshot.data ?? [];

          // Empty state
          if (!isLoading && announcements.isEmpty) {
            return const Center(
              child: Text(
                'No announcements yet',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            );
          }

          return Skeletonizer(
            enabled: isLoading,
            child: ListView.separated(
              itemCount: announcements.length > 3 ? 3 : announcements.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final announcement = announcements[index];

                return FutureBuilder(
                  future: getDeletedData(
                    announcement.createdBy,
                    announcement.id!,
                    announcement.isDeleted,
                  ),
                  builder: (context, userSnapshot) {
                    bool isUserLoading = userSnapshot.connectionState == ConnectionState.waiting;
                    final admin = userSnapshot.data?[0] as UserModel?;
                    UserModel? deletedAdmin;

                    if (announcement.isDeleted &&
                        userSnapshot.data != null &&
                        userSnapshot.data!.length > 1) {
                      deletedAdmin = userSnapshot.data![1];
                    }

                    return Skeletonizer(
                      enabled: isUserLoading,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           // const Icon(Icons.campaign_outlined, color: primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title or Deleted Info
                                  if (announcement.isDeleted)
                                    Text(
                                      deletedAdmin?.id == admin?.id
                                          ? 'This announcement was deleted'
                                          : 'This announcement was deleted by ${deletedAdmin?.name}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    )
                                  else
                                    Text(
                                      announcement.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                  const SizedBox(height: 6),

                                  // Admin name and time in one row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        admin?.name ?? "",
                                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                                      ),
                                      LiveTimeAgo(timestamp: announcement.createdAt),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    ),
  );
}



  Widget _buildSeeMoreButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: AnnouncementsListScreen(
                announcementService: AnnouncementService(),
                userService: UserService(),
                user: widget.user,
                specialRoleModel: widget.specialRoleModel,
              ),
            ),
          );
        },
        icon: const Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
        label: const Text('See more'),
      ),
    );
  }

  Widget _buildInfoCardSection({
    required double top,
    required IconData icon,
    required String title,
    required String subtitle,
    required UserModel user,
    required SpecialRole? specialRole,
    required VoidCallback onTap,
    required VoidCallback buttonOnTap
  }) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: _buildInfoCard(
        icon: icon,
        title: title,
        subtitle: subtitle,
        user: user,
        specialRole: specialRole,
        onTap: onTap,
        buttonOnTap: buttonOnTap
      ),
    );
  }

  Widget _buildInfoCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required UserModel user,
  required SpecialRole? specialRole,
  required VoidCallback onTap,
  required VoidCallback buttonOnTap,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 650;

      // Determine if button should show and what label it should have
      bool showButton = false;
      String buttonText = '';

      if (title == 'Discussion Rooms' &&
          user.userType == UserType.admin &&
          (specialRole == SpecialRole.superAdmin ||
              specialRole == SpecialRole.discussionRoomManager)) {
        showButton = true;
        buttonText = 'New';
      } else if (title == 'Suggestions' && user.userType == UserType.student) {
        showButton = true;
        buttonText = 'Post';
      }

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
                title: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (showButton)
                      ElevatedButton(
                        onPressed: buttonOnTap,
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0),
                          minimumSize: const WidgetStatePropertyAll(Size(40, 25)),
                          backgroundColor: const WidgetStatePropertyAll(whiteColor),
                          side: const WidgetStatePropertyAll(
                            BorderSide(width: 1, color: primaryColor),
                          ),
                          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) => states.contains(WidgetState.pressed)
                                ? primaryColor.withAlpha(25)
                                : null,
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(color: primaryColor),
                        ),
                      ),
                  ],
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
