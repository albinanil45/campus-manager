import 'package:campus_manager/firebase/announcement_service/announcement_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/announcement_model.dart';
import 'package:campus_manager/models/deleted_announcement_model.dart';
import 'package:campus_manager/models/special_role_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/widgets/confirmation_dialog.dart';
import 'package:campus_manager/widgets/live_time_ago.dart';
import 'package:campus_manager/widgets/loader_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AnnouncementsListScreen extends StatefulWidget {
  final UserModel user;
  final SpecialRoleModel? specialRoleModel;
  final AnnouncementService announcementService;
  final UserService userService;

  const AnnouncementsListScreen({
    super.key,
    required this.user,
    required this.specialRoleModel,
    required this.announcementService,
    required this.userService,
  });

  @override
  State<AnnouncementsListScreen> createState() =>
      _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  Future<List<dynamic>> getDeletedData(
      String uid, String announcementId, bool isDeleted) async {
    List<dynamic> list = [];
    final user = await widget.userService.getUser(uid);
    list.add(user);

    if (isDeleted) {
      final deletedData = await widget.announcementService
          .getDeletedAnnouncement(announcementId);
      final deletedAdmin =
          await widget.userService.getUser(deletedData!.deletedBy);
      list.add(deletedAdmin);
    }

    return list;
  }

  Future<void> deleteAnnouncement(AnnouncementModel announcement) async {
    bool isConfirm = await ConfirmationDialog.show(
      context: context,
      title: 'Confirm Deletion',
      message: 'Do you want to delete the announcement?',
      confirmText: 'Delete',
    );

    if (isConfirm) {
      LoaderDialog.show(context, message: 'Deleting...');
      announcement.isDeleted = true;

      await widget.announcementService.storeAnnouncement(announcement);

      final deletedAnnouncement = DeletedAnnouncementModel(
        announcementId: announcement.id!,
        deletedBy: widget.user.id,
        deletedAt: Timestamp.now(),
      );

      await widget.announcementService
          .storeDeletedAnnouncement(deletedAnnouncement);
      LoaderDialog.dismiss(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        title: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = MediaQuery.of(context).size.width;
            double maxContentWidth = 780;
            double horizontalMargin = (screenWidth - maxContentWidth) / 2;
            double leftPadding =
                screenWidth > maxContentWidth ? horizontalMargin : 16;

            return Padding(
              padding: EdgeInsets.only(left: leftPadding),
              child: const Text(
                'Announcements',
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<List<AnnouncementModel>>(
        stream: widget.announcementService.getActiveAnnouncementsStream(),
        builder: (context, snapshot) {
          bool isStreamLoading =
              snapshot.connectionState == ConnectionState.waiting;
          final announcements = snapshot.data ?? [];

          return Skeletonizer(
            enabled: isStreamLoading,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxContentWidth = 700;

                if (!isStreamLoading && announcements.isEmpty) {
                  return const Center(
                    child: Text(
                      'No announcements yet',
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
                      itemCount: announcements.length,
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
                            bool isUserLoading = userSnapshot.connectionState ==
                                ConnectionState.waiting;
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title and Content (with padding to avoid overlapping the delete icon)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 40),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
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
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              const SizedBox(height: 8),
                                              if (!announcement.isDeleted)
                                                Text(
                                                  announcement.content,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              const SizedBox(height: 8),
                                            ],
                                          ),
                                        ),

                                        // Admin Name and Time Row (no padding so time aligns right)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'By ${admin?.name ?? "Unknown"}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54),
                                            ),
                                            LiveTimeAgo(
                                                timestamp:
                                                    announcement.createdAt),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Delete icon top-right
                                    if (widget.user.userType ==
                                            UserType.admin &&
                                        (widget.specialRoleModel?.specialRole ==
                                                SpecialRole.superAdmin ||
                                            widget.specialRoleModel
                                                    ?.specialRole ==
                                                SpecialRole
                                                    .announcementManager) &&
                                        !announcement.isDeleted)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () =>
                                              deleteAnnouncement(announcement),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: primaryColor,
                                          ),
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
