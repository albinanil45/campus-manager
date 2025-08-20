import 'package:bubble/bubble.dart';
import 'package:campus_manager/firebase/message_service/message_service.dart';
import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/deleted_message_model.dart';
import 'package:campus_manager/models/discussion_room_model.dart';
import 'package:campus_manager/models/message_model.dart';
import 'package:campus_manager/models/student_course_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/widgets/message_bottom_sheet.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DiscussionRoomChatScreen extends StatefulWidget {
  final MessageService messageService;
  final UserModel user;
  final UserService userService;
  final DiscussionRoomModel discussionRoomModel;
  final StudentService studentService;
  const DiscussionRoomChatScreen({
    super.key,
    required this.messageService,
    required this.user,
    required this.discussionRoomModel,
    required this.userService,
    required this.studentService,
  });

  @override
  State<DiscussionRoomChatScreen> createState() =>
      _DiscussionRoomChatScreenState();
}

class _DiscussionRoomChatScreenState extends State<DiscussionRoomChatScreen> {
  List<UserModel> users = [];

  List<StudentCourseModel> studentCourseDetails = [];

  bool isUsersAndCourseLoading = false;

  void sendMessage(String content) async {
    final message = MessageModel(
      id: '',
      content: content,
      senderId: widget.user.id,
      createdAt: Timestamp.now(),
    );

    await widget.messageService.saveMessage(
      discussionRoomId: widget.discussionRoomModel.id,
      message: message,
    );
  }

  void fetchUsersAndCourses() async {
    setState(() {
      isUsersAndCourseLoading = true;
    });
    users = await widget.userService.getAllUsers();
    studentCourseDetails = await widget.studentService.getAllStudentCourses();
    setState(() {
      isUsersAndCourseLoading = false;
    });
  }

  void deleteMessage(MessageModel message) async {
    message.isDeleted = true;
    await widget.messageService.saveMessage(
      discussionRoomId: widget.discussionRoomModel.id,
      message: message,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUsersAndCourses();
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
            padding: EdgeInsets.only(
              left: leftPadding,
            ),
            child: Text(
              widget.discussionRoomModel.roomTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
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
                  child: Column(
                    children: [
                      _buildMessagesList(),
                      _buildMessageBar(),
                    ],
                  )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    return Expanded(
      child: StreamBuilder<List<MessageModel>>(
          stream:
              widget.messageService.getMessages(widget.discussionRoomModel.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                isUsersAndCourseLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData) {
              List<MessageModel> messages = snapshot.data!;

              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  bool isSender = message.senderId == widget.user.id;
                  return _buildMessageWidget(
                    isSender,
                    message,
                    () {
                      if (message.senderId == widget.user.id)
                        MessageBottomSheet.show(
                          height: 150,
                          context: context,
                          options: [
                            BottomSheetOption(
                              icon: Icons.delete_outline,
                              label: 'Delete',
                              onTap: () {
                                deleteMessage(message);
                              },
                            ),
                          ],
                        );
                    },
                  );
                },
              );
            }

            return const Center(
              child: Text('An error occured'),
            );
          }),
    );
  }

  Widget _buildMessageWidget(
      bool isSender, MessageModel message, VoidCallback onLongPress) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        child: Bubble(
          nip: isSender ? BubbleNip.rightTop : BubbleNip.leftTop,
          color: isSender ? primaryColor : Colors.grey.shade200,
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              !isSender
                  ? Text(
                      users
                          .firstWhere((user) => user.id == message.senderId)
                          .name,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSender ? whiteColor : blackColor,
                      ),
                    )
                  : const SizedBox(),
              Text(
                message.isDeleted
                    ? 'This message was deleted'
                    : message.content,
                style: TextStyle(
                  color: isSender ? whiteColor : blackColor,
                  fontStyle: message.isDeleted ? FontStyle.italic : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBar() {
    return MessageBar(
      onSend: (message) {
        if (message.isNotEmpty) {
          sendMessage(message);
        }
      },
      sendButtonColor: primaryColor,
      messageBarHintStyle: const TextStyle(
        fontSize: 14,
      ),
    );
  }
}
