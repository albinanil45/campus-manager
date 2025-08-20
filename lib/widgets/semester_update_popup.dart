import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';

Future<void> showSemesterUpdatePopup(BuildContext context) async {
  int selectedSemester = 1;

  await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Update Students by Semester",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 1; i <= 6; i++)
                    RadioListTile<int>(
                      title: Text("Semester $i"),
                      value: i,
                      groupValue: selectedSemester,
                      onChanged: (value) {
                        setState(() {
                          selectedSemester = value!;
                        });
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // close popup
                    if (selectedSemester < 6) {
                      await StudentService.incrementSemesterForStudents(
                        selectedSemester.toString(),
                      );
                    } else {
                      await StudentService.removeSemester6Students();
                    }
                  },
                  child: const Text("Update"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 40),
                    foregroundColor: whiteColor,
                  ),
                ),
              ],
            );
          },
        );
      });
}
