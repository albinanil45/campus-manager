import 'package:campus_manager/firebase/discussion_room_service/discussion_room_service.dart';
import 'package:campus_manager/firebase/message_service/message_service.dart';
import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/discussion_room_model.dart';
import 'package:campus_manager/models/special_role_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/screens/discussion_room_chat_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/widgets/live_time_ago.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DiscussionRoomsListScreen extends StatelessWidget {
  final DiscussionRoomService discussionRoomService;
  final UserService userService;
  final UserModel currentUser;
  final SpecialRoleModel? specialRoleModel;

  const DiscussionRoomsListScreen({
    super.key,
    required this.discussionRoomService,
    required this.userService,
    required this.currentUser,
    required this.specialRoleModel,
  });

  void _closeDiscussionRoom(DiscussionRoomModel room, String outcome) async {
    room.isClosed = true;
    room.outcome = outcome;
    room.closedBy = currentUser.id;
    await discussionRoomService.createDiscussionRoom(room);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBodySection(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      foregroundColor: whiteColor,
      title: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double horizontalMargin = (screenWidth - 690) / 2;
          double leftPadding = screenWidth > 690 ? horizontalMargin + 14 : 14;

          return Padding(
            padding: EdgeInsets.only(left: leftPadding),
            child: const Text(
              'Discussion Rooms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildBodySection() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 550,
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildRoomsList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomsList() {
    return StreamBuilder<List<DiscussionRoomModel>>(
      stream: discussionRoomService.getDiscussionRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeletonList();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No rooms created yet'));
        }

        final rooms = snapshot.data!;
        return ListView.separated(
          itemCount: rooms.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _buildRoomTile(room);
          },
        );
      },
    );
  }

  Widget _buildRoomTile(DiscussionRoomModel room) {
    return FutureBuilder<List<UserModel?>>(
      future: Future.wait([
        userService.getUser(room.createdBy), // creator
        if (room.closedBy != null)
          userService.getUser(room.closedBy!)
        else
          Future.value(null), // closedBy
      ]),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        final user = snapshot.data?[0];
        final closedUser = snapshot.data?[1];

        return Skeletonizer(
          ignoreContainers: true,
          enabled: isLoading,
          child: ListTile(
            onLongPress: () {
              if (!room.isClosed &&
                  (specialRoleModel != null &&
                      (specialRoleModel!.specialRole ==
                              SpecialRole.discussionRoomManager ||
                          specialRoleModel!.specialRole ==
                              SpecialRole.superAdmin))) {
                showCloseRoomDialog(context, room);
              }
            },
            onTap: () {
              if (!room.isClosed) {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: DiscussionRoomChatScreen(
                      userService: UserService(),
                      studentService: StudentService(),
                      user: currentUser,
                      messageService: MessageService(),
                      discussionRoomModel: room,
                    ),
                  ),
                );
              }
            },
            contentPadding: EdgeInsets.zero,
            title: Text(
              room.roomTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !room.isClosed
                      ? Text(
                          room.roomDescription,
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(
                          room.outcome!,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                  const SizedBox(height: 12),
                  if (user != null)
                    Text(
                      'Created by ${user.name}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (room.isClosed && closedUser != null)
                    Text(
                      'Closed by ${closedUser.name}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStamp(room.isClosed),
                LiveTimeAgo(timestamp: room.createdAt),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStamp(bool isClosed) {
    return Container(
      height: 24,
      width: 64,
      decoration: BoxDecoration(
        color: isClosed ? Colors.orange : Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              isClosed ? 'closed' : 'open',
              style: TextStyle(
                color: isClosed ? Colors.orange : Colors.green,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Skeletonizer(
          enabled: true,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Room Title'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text('Room Description'),
                Text('Created by ...', style: TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //_buildStamp(),
                Text('...'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showCloseRoomDialog(
      BuildContext context, DiscussionRoomModel room) async {
    final TextEditingController outcomeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Close the Room",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: outcomeController,
              maxLines: 6, // makes it a large textbox
              decoration: InputDecoration(
                hintText: "Write the outcome here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close popup
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String outcome = outcomeController.text.trim();
                if (outcome.isNotEmpty) {
                  _closeDiscussionRoom(room, outcome);

                  Navigator.of(context).pop(); // close popup after confirm
                }
              },
              child: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(120, 40),
                foregroundColor: whiteColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
