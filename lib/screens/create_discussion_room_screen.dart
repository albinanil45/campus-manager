import 'package:campus_manager/firebase/discussion_room_service/discussion_room_service.dart';
import 'package:campus_manager/models/discussion_room_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateDiscussionRoomScreen extends StatelessWidget {

  final UserModel user;
  final DiscussionRoomService discussionRoomService;
  CreateDiscussionRoomScreen({super.key, required this.user, required this.discussionRoomService});

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  void createRoom (BuildContext context)async{
    if(titleController.text.isEmpty || descriptionController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields'
          ),
        ),
      );
      return;
    }

    isLoading.value = true;
    final discussionRoom = DiscussionRoomModel(
      id: '',
      roomTitle: titleController.text,
      roomDescription: descriptionController.text,
      createdBy: user.id,
      createdAt: Timestamp.now(),
    );

    await discussionRoomService.createDiscussionRoom(discussionRoom);
    isLoading.value = false;
    titleController.clear();
    descriptionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Discussion room created'
        ),
      ),
    );
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
          // Get screen width and center the 600 box
          double screenWidth = MediaQuery.of(context).size.width;
          double horizontalMargin = (screenWidth - 690) / 2;
          double leftPadding = screenWidth > 690 ? horizontalMargin + 14 : 14;

          return Padding(
            padding: EdgeInsets.only(left: leftPadding),
            child: const Text(
              'Create Discussion Room',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      titleSpacing: 0, // To prevent Flutter from adding default spacing
    );
  }

  Widget _buildBodySection() {
    return SafeArea(
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
                        decoration: InputDecoration(
                          hintText: 'Room title'
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        minLines: 4,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Room description'
                        ),
                      ),
                      SizedBox(height: 16),
                      ValueListenableBuilder(
                        valueListenable: isLoading,
                        builder:(context, value, child) => ElevatedButton(
                          onPressed:()=> createRoom(context),
                          child: !value 
                          ? Text(
                            'Create room',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                            ),
                          ) : SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: whiteColor,
                              strokeWidth: 2,
                            ),
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
