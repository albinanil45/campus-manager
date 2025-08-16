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
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      itemCount: complaints.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final complaint = complaints[index];

                        return FutureBuilder<UserModel?>(
                          future:
                              widget.userService.getUser(complaint.studentId),
                          builder: (context, userSnapshot) {
                            bool isUserLoading = userSnapshot.connectionState ==
                                ConnectionState.waiting;
                            final student = userSnapshot.data;

                            return Skeletonizer(
                              enabled: isUserLoading,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Complaint Content
                                    if (complaint.isDeleted)
                                      const Text(
                                        'This complaint was deleted',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      )
                                    else
                                      Text(
                                        complaint.content,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    const SizedBox(height: 8),

                                    // Student Name + Time
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'By ${student?.name ?? "Unknown"}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                        LiveTimeAgo(
                                            timestamp: complaint.createdAt),
                                      ],
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
