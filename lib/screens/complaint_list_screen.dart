import 'package:campus_manager/firebase/complaint_service/complaint_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/complaint_model.dart';
import 'package:campus_manager/models/special_role_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/widgets/live_time_ago.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ComplaintListScreen extends StatefulWidget {
  final UserModel user;
  final SpecialRoleModel? specialRoleModel;
  final ComplaintService complaintService;
  final UserService userService;

  const ComplaintListScreen({
    super.key,
    required this.user,
    required this.specialRoleModel,
    required this.userService,
    required this.complaintService,
  });

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  Future<void> _submitFeedback(
      ComplaintModel complaint, String feedback) async {
    complaint.isReviewed = true;
    complaint.feedback = feedback;
    await widget.complaintService.storeComplaint(complaint);
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
              child: const Text('Complaints'),
            );
          },
        ),
      ),
      body: StreamBuilder<List<ComplaintModel>>(
        stream: widget.complaintService.getComplaintsStream(),
        builder: (context, snapshot) {
          bool isStreamLoading =
              snapshot.connectionState == ConnectionState.waiting;
          final complaints = snapshot.data ?? [];

          return Skeletonizer(
            enabled: isStreamLoading,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxContentWidth = 700;

                if (!isStreamLoading && complaints.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Complaints yet',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      itemCount: complaints.length,
                      itemBuilder: (context, index) {
                        final complaint = complaints[index];

                        return FutureBuilder<UserModel?>(
                          future:
                              widget.userService.getUser(complaint.studentId),
                          builder: (context, userSnapshot) {
                            bool isUserLoading = userSnapshot.connectionState ==
                                ConnectionState.waiting;
                            final student = userSnapshot.data;

                            return Card(
                              color: whiteColor,
                              child: Skeletonizer(
                                enabled: isUserLoading,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: complaint.isDeleted
                                        ? const Text(
                                            'This complaint was deleted',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          )
                                        : Text(
                                            complaint.content,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (complaint.isReviewed)
                                            Text(
                                              'Feedback : ${complaint.feedback}',
                                            ),
                                          SizedBox(height: 2),
                                          Text(
                                            'By ${student?.name ?? "Unknown"}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: FittedBox(
                                      // 🔑 prevents overflow
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (complaint.isDeleted)
                                            SizedBox()
                                          else if (!complaint.isReviewed)
                                            PopupMenuButton(
                                              color: blackColor,
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'review',
                                                  child: Text(
                                                    'Review',
                                                    style: TextStyle(
                                                        color: whiteColor),
                                                  ),
                                                ),
                                              ],
                                              onSelected: (value) {
                                                if (value == 'review') {
                                                  _showFeedbackDialog(
                                                      context, complaint);
                                                }
                                              },
                                            )
                                          else
                                            Text(
                                              'REVIEWED',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.green,
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          LiveTimeAgo(
                                              timestamp: complaint.createdAt),
                                        ],
                                      ),
                                    ),
                                  ),
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

  void _showFeedbackDialog(BuildContext context, ComplaintModel complaint) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Write Feedback",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: feedbackController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Enter your feedback here...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close popup
              },
              child: const Text(
                "Cancel",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: whiteColor,
                minimumSize: Size(120, 40),
              ),
              onPressed: () {
                final feedback = feedbackController.text.trim();
                if (feedback.isNotEmpty) {
                  // Handle review submission
                  _submitFeedback(complaint, feedback);

                  Navigator.pop(context); // Close popup after submission
                }
              },
              child: const Text(
                "Review",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
