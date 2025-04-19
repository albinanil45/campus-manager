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
  State<AnnouncementsListScreen> createState() => _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  Future<List<dynamic>> getDeletedData(String uid, String announcementId, bool isDeleted) async {
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

      await widget.announcementService.storeDeletedAnnouncement(deletedAnnouncement);
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
            double leftPadding = screenWidth > maxContentWidth ? horizontalMargin : 16;

            return Padding(
              padding: EdgeInsets.only(left: leftPadding),
              child: const Text(
                'Announcements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
      ),

      body: StreamBuilder<List<AnnouncementModel>>(
        stream: widget.announcementService.getActiveAnnouncementsStream(),
        builder: (context, snapshot) {
          bool isStreamLoading = snapshot.connectionState == ConnectionState.waiting;
          final announcements = snapshot.data ?? [];

          return Skeletonizer(
            enabled: isStreamLoading,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxContentWidth = 700;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                              child: ListTile(
                                title: announcement.isDeleted
                                    ? (deletedAdmin?.id == admin?.id
                                        ? const Text(
                                            'This announcement was deleted',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          )
                                        : Text(
                                            'This announcement was deleted by ${deletedAdmin?.name}',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ))
                                    : Text(
                                        announcement.title,
                                        style: const TextStyle(fontSize: 16),
                                      ),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 13),

                                    if (!announcement.isDeleted)
                                      Text(
                                        announcement.content,
                                        style: const TextStyle(fontSize: 14),
                                      ),

                                    Text(
                                      'By ${admin?.name}',
                                      style: const TextStyle(fontSize: 12),
                                    ),

                                    const SizedBox(height: 2),
                                    LiveTimeAgo(timestamp: announcement.createdAt),
                                  ],
                                ),

                                trailing: widget.user.userType == UserType.admin &&
                                        (widget.specialRoleModel?.specialRole == SpecialRole.superAdmin ||
                                            widget.specialRoleModel?.specialRole == SpecialRole.announcementManager) &&
                                        !announcement.isDeleted
                                    ? IconButton(
                                        onPressed: () => deleteAnnouncement(announcement),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: primaryColor,
                                        ),
                                      )
                                    : null,
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
