import 'package:campus_manager/firebase/suggestion_service/suggestion_service.dart';
import 'package:campus_manager/helpers/format_category.dart';
import 'package:campus_manager/models/student_course_model.dart';
import 'package:campus_manager/models/suggestion_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';

class ReviewSuggestionScreen extends StatelessWidget {
  final SuggestionModel suggestion;
  final String studentName;
  final UserModel user;
  final StudentCourseModel course;
  final SuggestionService suggestionService;
  ReviewSuggestionScreen(
      {super.key, required this.suggestion, required this.studentName, required this.course, required this.suggestionService, required this.user});

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final feedbackController = TextEditingController();

  Future<void> postReview (BuildContext context)async{
    if(feedbackController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add feedback'
          )
        )
      );
      return;
    }
    isLoading.value = true;
    suggestion.feedback = feedbackController.text;
    suggestion.isReviewed = true;
    suggestion.reviewedBy = user.id;
    await suggestionService.storeSuggestion(suggestion);
    isLoading.value = false;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Suggestion Reviewed'
          )
        )
      );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context,'refresh');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
          title: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = MediaQuery.of(context).size.width;
              double maxContentWidth = 680;
              double horizontalMargin = (screenWidth - maxContentWidth) / 2;
              double leftPadding =
                  screenWidth > maxContentWidth ? horizontalMargin : 16;
      
              return Padding(
                padding: EdgeInsets.only(left: leftPadding),
                child: const Text(
                  'Review Suggestion',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
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
                          ListTile(
                            title: Text(suggestion.content),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Category • ${FormatCategory.formatCategoryName(suggestion.category)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(
                                  height: 10
                                ),
                                Text(
                                  'By $studentName',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'S${course.semester} ${course.course}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 26,
                          ),
                          TextField(
                            controller: feedbackController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                                label: Text('Feedback'),
                                labelStyle:
                                    TextStyle(fontSize: 14, color: greyColor)),
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
                                    isLoading.value?null:postReview(context);
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
                                          'Review',
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
      ),
    );
  }
}
