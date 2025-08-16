import 'package:campus_manager/firebase/complaint_service/complaint_service.dart';
import 'package:campus_manager/models/complaint_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostComplaintScreen extends StatelessWidget {
  final UserModel user;
  final ComplaintService complaintService;
  PostComplaintScreen(
      {super.key, required this.user, required this.complaintService});

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final contentController = TextEditingController();

  Future<void> postSuggestion(BuildContext context) async {
    if (contentController.text.isEmpty) {
      showError(context, 'Please fill all fields');
      return;
    }
    isLoading.value = true;
    final complaint = ComplaintModel(
        id: null,
        studentId: user.id,
        content: contentController.text,
        feedback: null,
        isDeleted: false,
        isReviewed: false,
        createdAt: Timestamp.now());
    await complaintService.storeComplaint(complaint);
    showError(context, 'Complaint Posted');
    contentController.clear();
    isLoading.value = false;
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 550,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        _buildContentTextField(),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        _buildSubmitButton(),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
              'Post Complaint',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildContentTextField() {
    return TextField(
      controller: contentController,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        label: Text('Content'),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, loading, _) {
        return SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              isLoading.value ? null : postSuggestion(context);
            },
            child: loading
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
                    style: TextStyle(color: whiteColor, fontSize: 18),
                  ),
          ),
        );
      },
    );
  }
}
