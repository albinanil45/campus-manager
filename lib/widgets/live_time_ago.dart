import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class LiveTimeAgo extends StatefulWidget {
  final Timestamp timestamp;

  const LiveTimeAgo({super.key, required this.timestamp});

  @override
  State<LiveTimeAgo> createState() => _LiveTimeAgoState();
}

class _LiveTimeAgoState extends State<LiveTimeAgo> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      timeago.format(widget.timestamp.toDate()),
      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
    );
  }
}
