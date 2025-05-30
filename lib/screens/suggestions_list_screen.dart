import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/firebase/suggestion_service/suggestion_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/helpers/format_category.dart';
import 'package:campus_manager/models/deleted_suggestion_model.dart';
import 'package:campus_manager/models/special_role_model.dart';
import 'package:campus_manager/models/student_course_model.dart';
import 'package:campus_manager/models/suggestion_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/screens/review_suggestion_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/widgets/confirmation_dialog.dart';
import 'package:campus_manager/widgets/live_time_ago.dart';
import 'package:campus_manager/widgets/loader_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SuggestionsListScreen extends StatelessWidget {
  final UserModel user;
  final SpecialRole? specialRole;
  final SuggestionService suggestionService;
  final UserService userService;
  final StudentService studentService;

  const SuggestionsListScreen({
    super.key,
    required this.user,
    required this.specialRole,
    required this.suggestionService,
    required this.userService,
    required this.studentService,
  });

  Future<Map<String, dynamic>> getDeletedData(
      String uid, SuggestionModel suggestion, bool isDeleted) async {
    final Map<String, dynamic> data = {};

    final suggestedUser = await userService.getUser(uid);
    data['admin'] = suggestedUser;

    if (isDeleted) {
      final deletedData =
          await suggestionService.getDeletedSuggestion(suggestion.id!);
      final deletedAdmin = await userService.getUser(deletedData!.deletedBy);
      data['deletedAdmin'] = deletedAdmin;
    }

    final studentCourse = await studentService.getStudentCourse(uid);
    data['course'] = studentCourse;

    if (suggestion.isReviewed) {
      final reviewedUser = await userService.getUser(suggestion.reviewedBy!);
      data['reviewedUser'] = reviewedUser;
    }

    return data;
  }

  Future<void> deleteSuggestion(
      SuggestionModel suggestion, BuildContext context) async {
    bool isConfirm = await ConfirmationDialog.show(
      context: context,
      title: 'Confirm Deletion',
      message: 'Do you want to delete the announcement?',
      confirmText: 'Delete',
    );

    if (isConfirm) {
      LoaderDialog.show(context, message: 'Deleting...');
      suggestion.isDeleted = true;

      await suggestionService.storeSuggestion(suggestion);

      final deletedSuggestion = DeletedSuggestionModel(
        suggestionId: suggestion.id!,
        deletedBy: user.id,
        deletedAt: Timestamp.now(),
      );

      await suggestionService.storeDeletedSuggestion(deletedSuggestion);
      LoaderDialog.dismiss(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: user.userType == UserType.admin ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
          title: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = MediaQuery.of(context).size.width;
              double horizontalMargin = (screenWidth - 690) / 2;
              double leftPadding =
                  screenWidth > 690 ? horizontalMargin + 14 : 14;

              return Padding(
                padding: EdgeInsets.only(left: leftPadding),
                child: const Text(
                  'Suggestions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
          titleSpacing: 0,
          bottom: user.userType == UserType.admin
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: whiteColor,
                    child: const TabBar(
                      dividerColor: whiteColor,
                      labelColor: blackColor,
                      unselectedLabelColor: greyColor,
                      indicatorColor:
                          primaryColor, // Customize indicator if needed
                      indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(color: primaryColor)),
                      tabs: [
                        Tab(text: 'Public'),
                        Tab(text: 'Private'),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: user.userType == UserType.admin
                  ? TabBarView(
                      children: [
                        SuggestionsTabContent(
                          suggestionsListScreen: SuggestionsListScreen(
                              studentService: StudentService(),
                              specialRole: specialRole,
                              user: user,
                              suggestionService: suggestionService,
                              userService: userService),
                          specialRole: specialRole,
                          user: user,
                          suggestionService: SuggestionService(),
                          userService: UserService(),
                        ),
                        PrivateSuggestionsTab(
                          suggestionService: suggestionService,
                          userService: userService,
                          user: user,
                          specialRole: specialRole,
                          suggestionsListScreen: SuggestionsListScreen(
                              studentService: StudentService(),
                              specialRole: specialRole,
                              user: user,
                              suggestionService: suggestionService,
                              userService: userService),
                        )
                      ],
                    )
                  : SuggestionsTabContent(
                      suggestionsListScreen: SuggestionsListScreen(
                          studentService: StudentService(),
                          specialRole: specialRole,
                          user: user,
                          suggestionService: suggestionService,
                          userService: userService),
                      specialRole: specialRole,
                      user: user,
                      suggestionService: SuggestionService(),
                      userService: UserService(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class SuggestionsTabContent extends StatelessWidget {
  final SuggestionService suggestionService;
  final UserService userService;
  final UserModel user;
  final SpecialRole? specialRole;
  final SuggestionsListScreen suggestionsListScreen;

  const SuggestionsTabContent(
      {super.key,
      required this.suggestionService,
      required this.userService,
      required this.user,
      required this.specialRole,
      required this.suggestionsListScreen});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SuggestionModel>>(
      stream: suggestionService.getSuggestionsStream(),
      builder: (context, snapshot) {
        bool isStreamLoading =
            snapshot.connectionState == ConnectionState.waiting;
        final suggestions =
            (snapshot.data ?? []).where((s) => s.isPublic == true).toList();

        return Skeletonizer(
          enabled: isStreamLoading,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxContentWidth = 700;

              if (!isStreamLoading && suggestions.isEmpty) {
                return const Center(
                  child: Text(
                    'No suggestions yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];

                      return StatefulBuilder(
                        builder: (context, setState) => FutureBuilder(
                          future: suggestionsListScreen.getDeletedData(
                            suggestion.studentId,
                            suggestion,
                            suggestion.isDeleted,
                          ),
                          builder: (context, userSnapshot) {
                            bool isUserLoading = userSnapshot.connectionState ==
                                ConnectionState.waiting;
                            final data = userSnapshot.data;
                            UserModel? admin;
                            UserModel? deletedAdmin;
                            StudentCourseModel? course;
                            UserModel? reviewedUser;

                            if (data is Map<String, dynamic>) {
                              admin = data['admin'] as UserModel?;
                              deletedAdmin =
                                  data['deletedAdmin'] as UserModel?;
                              course =
                                  data['course'] as StudentCourseModel?;
                              reviewedUser =
                                  data['reviewedUser'] as UserModel?;
                            }

                            return Skeletonizer(
                              enabled: isUserLoading,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Stack(
                                  children: [
                                    // Main content
                                    Padding(
                                      padding: const EdgeInsets.only(right: 60),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (suggestion.isDeleted) ...[
                                            SizedBox(
                                              width: 220,
                                              child: Text(
                                                deletedAdmin?.id == admin?.id
                                                    ? 'This suggestion was deleted'
                                                    : 'This suggestion was deleted by ${deletedAdmin?.name}',
                                                style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 14,
                                            ),
                                            Text(
                                              'By ${admin?.name ?? "Unknown"}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54),
                                            ),
                                            Text(
                                              'S${course?.semester} ${course?.course}',
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12),
                                            ),
                                          ] else ...[
                                            Text(
                                              suggestion.content,
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                            const SizedBox(height: 18),
                                            Text(
                                              'Category • ${FormatCategory.formatCategoryName(suggestion.category)}',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(height: 14),
                                            if (suggestion.isReviewed) ...[
                                              Text(
                                                'Reviewed By ${reviewedUser?.name}',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black54),
                                              ),
                                              Text(
                                                'Feedback : ${suggestion.feedback}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54
                                                ),
                                              ),
                                              const SizedBox(height: 14)
                                            ],
                                            Text(
                                              'By ${admin?.name ?? "Unknown"}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54),
                                            ),
                                            Text(
                                              'S${course?.semester} ${course?.course}',
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Time & status
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (!suggestion.isDeleted)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              height: 24,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: suggestion.isReviewed
                                                      ? Colors.green
                                                      : Colors.orange,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  suggestion.isReviewed
                                                      ? 'Reviewed'
                                                      : 'Pending',
                                                  style: TextStyle(
                                                    color: suggestion.isReviewed
                                                        ? Colors.green
                                                        : Colors.orange,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          LiveTimeAgo(
                                              timestamp: suggestion.createdAt),
                                        ],
                                      ),
                                    ),

                                    // PopupMenuButton top-right
                                    if (!suggestion.isDeleted &&
                                        ((user.userType == UserType.admin &&
                                                (specialRole ==
                                                        SpecialRole
                                                            .superAdmin ||
                                                    specialRole ==
                                                        SpecialRole
                                                            .suggestionManager)) ||
                                            (user.id == suggestion.studentId)))
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: PopupMenuButton<String>(
                                          color: blackColor,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          onSelected: (value) {
                                            if (value == 'delete') {
                                              suggestionsListScreen
                                                  .deleteSuggestion(
                                                      suggestion, context);
                                            } else if (value == 'review') {
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .rightToLeftWithFade,
                                                      child:
                                                          ReviewSuggestionScreen(
                                                        user: user,
                                                        suggestionService:
                                                            SuggestionService(),
                                                        course: course!,
                                                        studentName:
                                                            admin!.name,
                                                        suggestion: suggestion,
                                                      ))).then((value) {
                                                if (value == 'refresh') {
                                                  setState(() {});
                                                }
                                              });
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            final items =
                                                <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('Delete',
                                                    style: TextStyle(
                                                        color: whiteColor)),
                                              ),
                                            ];

                                            if (user.userType ==
                                                    UserType.admin &&
                                                (specialRole ==
                                                        SpecialRole
                                                            .superAdmin ||
                                                    specialRole ==
                                                        SpecialRole
                                                            .suggestionManager) &&
                                                !suggestion.isReviewed) {
                                              items.add(
                                                const PopupMenuItem<String>(
                                                  value: 'review',
                                                  child: Text(
                                                      'Mark as Reviewed',
                                                      style: TextStyle(
                                                          color: whiteColor)),
                                                ),
                                              );
                                            }

                                            return items;
                                          },
                                          icon: const Icon(Icons.more_vert,
                                              color: blackColor),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class PrivateSuggestionsTab extends StatelessWidget {
  final SuggestionService suggestionService;
  final UserService userService;
  final UserModel user;
  final SpecialRole? specialRole;
  final SuggestionsListScreen suggestionsListScreen;
  const PrivateSuggestionsTab(
      {super.key,
      required this.suggestionService,
      required this.userService,
      required this.user,
      required this.specialRole,
      required this.suggestionsListScreen});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SuggestionModel>>(
      stream: suggestionService.getSuggestionsStream(),
      builder: (context, snapshot) {
        bool isStreamLoading =
            snapshot.connectionState == ConnectionState.waiting;
        final suggestions =
            (snapshot.data ?? []).where((s) => s.isPublic == false).toList();

        return Skeletonizer(
          enabled: isStreamLoading,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxContentWidth = 700;

              if (!isStreamLoading && suggestions.isEmpty) {
                return const Center(
                  child: Text(
                    'No suggestions yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];

                      return StatefulBuilder(
                        builder: (context, setState) => FutureBuilder(
                          future: suggestionsListScreen.getDeletedData(
                            suggestion.studentId,
                            suggestion,
                            suggestion.isDeleted,
                          ),
                          builder: (context, userSnapshot) {
                            bool isUserLoading = userSnapshot.connectionState ==
                                ConnectionState.waiting;
                            final data = userSnapshot.data;
                            UserModel? admin;
                            UserModel? deletedAdmin;
                            StudentCourseModel? course;
                            UserModel? reviewedUser;

                            if (data is Map<String, dynamic>) {
                              admin = data['admin'] as UserModel?;
                              deletedAdmin =
                                  data['deletedAdmin'] as UserModel?;
                              course =
                                  data['course'] as StudentCourseModel?;
                              reviewedUser =
                                  data['reviewedUser'] as UserModel?;
                            }

                            return Skeletonizer(
                                enabled: isUserLoading,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Stack(
                                    children: [
                                      // Main content
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 60),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (suggestion.isDeleted) ...[
                                              SizedBox(
                                                width: 220,
                                                child: Text(
                                                  deletedAdmin?.id == admin?.id
                                                      ? 'This suggestion was deleted'
                                                      : 'This suggestion was deleted by ${deletedAdmin?.name}',
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 14,
                                              ),
                                              Text(
                                                'By ${admin?.name ?? "Unknown"}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54),
                                              ),
                                              Text(
                                                'S${course?.semester} ${course?.course}',
                                                style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12),
                                              ),
                                            ] else ...[
                                              Text(
                                                suggestion.content,
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                              const SizedBox(height: 18),
                                              Text(
                                                'Category • ${FormatCategory.formatCategoryName(suggestion.category)}',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black54),
                                              ),
                                              const SizedBox(height: 14),
                                              if (suggestion.isReviewed) ...[
                                                Text(
                                                  'Reviewed By ${reviewedUser?.name}',
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54),
                                                ),
                                                Text(
                                                'Feedback : ${suggestion.feedback}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54
                                                ),
                                              ),
                                                const SizedBox(height: 14),
                                              ],
                                              Text(
                                                'By ${admin?.name ?? "Unknown"}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54),
                                              ),
                                              Text(
                                                'S${course?.semester} ${course?.course}',
                                                style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Time & status
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            if (!suggestion.isDeleted)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: suggestion.isReviewed
                                                        ? Colors.green
                                                        : Colors.orange,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    suggestion.isReviewed
                                                        ? 'Reviewed'
                                                        : 'Pending',
                                                    style: TextStyle(
                                                      color:
                                                          suggestion.isReviewed
                                                              ? Colors.green
                                                              : Colors.orange,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            LiveTimeAgo(
                                                timestamp:
                                                    suggestion.createdAt),
                                          ],
                                        ),
                                      ),

                                      // PopupMenuButton top-right
                                      if (!suggestion.isDeleted &&
                                          ((user.userType == UserType.admin &&
                                                  (specialRole ==
                                                          SpecialRole
                                                              .superAdmin ||
                                                      specialRole ==
                                                          SpecialRole
                                                              .suggestionManager)) ||
                                              (user.id ==
                                                  suggestion.studentId)))
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: PopupMenuButton<String>(
                                            color: blackColor,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                suggestionsListScreen
                                                    .deleteSuggestion(
                                                        suggestion, context);
                                              } else if (value == 'review') {
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType
                                                            .rightToLeftWithFade,
                                                        child:
                                                            ReviewSuggestionScreen(
                                                          user: user,
                                                          suggestionService:
                                                              SuggestionService(),
                                                          course: course!,
                                                          studentName:
                                                              admin!.name,
                                                          suggestion:
                                                              suggestion,
                                                        ))).then((value) {
                                                  if (value == 'refresh') {
                                                    setState(() {});
                                                  }
                                                });
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) {
                                              final items =
                                                  <PopupMenuEntry<String>>[
                                                const PopupMenuItem<String>(
                                                  value: 'delete',
                                                  child: Text('Delete',
                                                      style: TextStyle(
                                                          color: whiteColor)),
                                                ),
                                              ];

                                              if (user.userType ==
                                                      UserType.admin &&
                                                  (specialRole ==
                                                          SpecialRole
                                                              .superAdmin ||
                                                      specialRole ==
                                                          SpecialRole
                                                              .suggestionManager) &&
                                                  !suggestion.isReviewed) {
                                                items.add(
                                                  const PopupMenuItem<String>(
                                                    value: 'review',
                                                    child: Text(
                                                        'Mark as Reviewed',
                                                        style: TextStyle(
                                                            color: whiteColor)),
                                                  ),
                                                );
                                              }

                                              return items;
                                            },
                                            icon: const Icon(Icons.more_vert,
                                                color: blackColor),
                                          ),
                                        ),
                                    ],
                                  ),
                                ));
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
