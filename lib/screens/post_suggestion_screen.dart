import 'package:campus_manager/firebase/suggestion_service/suggestion_service.dart';
import 'package:campus_manager/helpers/format_category.dart';
import 'package:campus_manager/models/suggestion_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostSuggestionScreen extends StatelessWidget {
  final UserModel user;
  final SuggestionService suggestionService;
  PostSuggestionScreen(
      {super.key, required this.user, required this.suggestionService});

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isPublic = ValueNotifier(false);
  final ValueNotifier<SuggestionCategories?> selectedCategory =
      ValueNotifier(null);

  final contentController = TextEditingController();

  Future<void> postSuggestion(BuildContext context) async {
    if (contentController.text.isEmpty || selectedCategory.value == null) {
      showError(context, 'Please fill all fields');
      return;
    }
    isLoading.value = true;
    final suggestion = SuggestionModel(
        id: null,
        studentId: user.id,
        content: contentController.text.trim(),
        category: selectedCategory.value!,
        isPublic: isPublic.value,
        reviewedBy: null,
        feedback: null,
        isDeleted: false,
        isReviewed: false,
        createdAt: Timestamp.now());
    await suggestionService.storeSuggestion(suggestion);
    showError(context, 'Suggestion Posted');
    selectedCategory.value = null;
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
                        _buildCategoryDropdown(),
                        const SizedBox(height: 20),
                        _buildContentTextField(),
                        const SizedBox(height: 20),
                        _buildVisibilityRadios(),
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
              'Post Suggestion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildCategoryDropdown() {
    return ValueListenableBuilder<SuggestionCategories?>(
      valueListenable: selectedCategory,
      builder: (context, value, _) {
        return DropdownButtonFormField<SuggestionCategories>(
          value: value,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: SuggestionCategories.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(FormatCategory.formatCategoryName(category)),
            );
          }).toList(),
          onChanged: (newValue) => selectedCategory.value = newValue,
        );
      },
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

  Widget _buildVisibilityRadios() {
    return ValueListenableBuilder<bool>(
      valueListenable: isPublic,
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visibility',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Private'),
                    value: false,
                    groupValue: value,
                    activeColor: primaryColor,
                    onChanged: (val) => isPublic.value = val!,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Public'),
                    value: true,
                    groupValue: value,
                    activeColor: primaryColor,
                    onChanged: (val) => isPublic.value = val!,
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
