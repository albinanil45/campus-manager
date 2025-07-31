import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';

class BottomSheetOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  BottomSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class MessageBottomSheet {
  static void show({
    required BuildContext context,
    required List<BottomSheetOption> options,
    double height = 300,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dragging handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Options List
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      leading: Icon(
                        option.icon,
                        color: primaryColor,
                      ),
                      title: Text(option.label),
                      onTap: () {
                        Navigator.pop(context); // close the sheet
                        option.onTap(); // trigger callback
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
