import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog {
  /// Shows a customizable confirmation dialog and returns true if user confirms
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.red,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(100, 35)
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                confirmText,
                style: const TextStyle(
                  color: whiteColor
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
