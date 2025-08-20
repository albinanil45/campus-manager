import 'package:flutter/material.dart';

class PendingOrRemovedScreen extends StatelessWidget {
  final bool isPending;
  const PendingOrRemovedScreen({super.key, required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          isPending
              ? 'Waiting for admin approval'
              : 'You are no longer a part of this institution',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
