import 'package:campus_manager/firebase/announcement_service/announcement_service.dart';
import 'package:campus_manager/models/announcement_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostAnnouncementScreen extends StatefulWidget {
  final AnnouncementService announcementService;
  final UserModel user;
  const PostAnnouncementScreen(
      {super.key, required this.announcementService, required this.user});

  @override
  State<PostAnnouncementScreen> createState() => _PostAnnouncementScreenState();
}

class _PostAnnouncementScreenState extends State<PostAnnouncementScreen> {
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final titleController = TextEditingController();

  final contentController = TextEditingController();

  Future<void> postAnnouncement(BuildContext context) async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      showError(context, 'Please fill all fields');
      return;
    }
    isLoading.value = true;
    final AnnouncementModel announcement = AnnouncementModel(
      id: null,
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      createdBy: widget.user.id,
      createdAt: Timestamp.now(),
      isDeleted: false,
    );
    await widget.announcementService.storeAnnouncement(announcement);
    isLoading.value = false;
    titleController.clear();
    contentController.clear();
    showError(context, 'Announcement Posted');
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Get screen width and center the 600 box
            double screenWidth = MediaQuery.of(context).size.width;
            double horizontalMargin = (screenWidth - 690) / 2;
            double leftPadding = screenWidth > 690 ? horizontalMargin + 14 : 14;

            return Padding(
              padding: EdgeInsets.only(left: leftPadding),
              child: const Text(
                'Post Announcement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
        titleSpacing: 0, // To prevent Flutter from adding default spacing
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 550,
                    minHeight: constraints.maxHeight, // Fill height if needed
                  ),
                  child: IntrinsicHeight(
                    // Helps the column take up only the required height
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: titleController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            label: Text('Title'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: contentController,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            label: Text('Content'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder(
                          valueListenable: isLoading,
                          builder: (context, value, child) {
                            return SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                                onPressed: () async {
                                  isLoading.value
                                      ? null
                                      : await postAnnouncement(context);
                                },
                                child: isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: whiteColor,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Post',
                                        style: TextStyle(
                                            color: whiteColor, fontSize: 18),
                                      ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
