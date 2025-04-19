import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';

class LoaderDialog {
  /// Show the loader dialog
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss on tap outside
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
          ),
          content: Row(
            children: [
              SizedBox(
                height: 23,
                width: 23,
                child: const CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 20,),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Dismiss the loader dialog
  static void dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
