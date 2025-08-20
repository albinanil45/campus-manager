import 'package:campus_manager/firebase/complaint_service/complaint_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/complaint_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/widgets/live_time_ago.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentComplaintsListScreen extends StatefulWidget {
  final UserModel user;
  final ComplaintService complaintService;
  final UserService userService;

  const StudentComplaintsListScreen({
    super.key,
    required this.user,
    required this.userService,
    required this.complaintService,
  });

  @override
  State<StudentComplaintsListScreen> createState() =>
      _StudentComplaintsListScreenState();
}

class _StudentComplaintsListScreenState
    extends State<StudentComplaintsListScreen> {
  Future<void> _deleteComplaint(ComplaintModel complaint) async {
    complaint.isDeleted = true;
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
              child: const Text('My Complaints'),
            );
          },
        ),
      ),
      body: StreamBuilder<List<ComplaintModel>>(
        stream: widget.complaintService
            .getComplaintsByStudentStream(widget.user.id),
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
                      'You have not posted any complaints yet',
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

                          return Card(
                            color: whiteColor,
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
                                        style: const TextStyle(fontSize: 16),
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
                                    ],
                                  ),
                                ),
                                trailing: FittedBox(
                                  // 🔑 prevents overflow
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (complaint.isDeleted)
                                        SizedBox()
                                      else if (!complaint.isReviewed)
                                        PopupMenuButton(
                                          color: blackColor,
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: whiteColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            if (value == 'delete') {
                                              _deleteComplaint(complaint);
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
                                        timestamp: complaint.createdAt,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
