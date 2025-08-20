import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';

class RequestsListScreen extends StatefulWidget {
  final UserService userService;
  const RequestsListScreen({super.key, required this.userService});

  @override
  State<RequestsListScreen> createState() => _RequestsListScreenState();
}

class _RequestsListScreenState extends State<RequestsListScreen> {
  bool _isRequestsLoading = false;
  List<UserModel> _pendingUsers = [];

  Future<void> _fetchRequests() async {
    setState(() {
      _isRequestsLoading = true;
    });
    final pending = await widget.userService.getPendingUsers();
    setState(() {
      _pendingUsers = pending;
      _isRequestsLoading = false;
    });
  }

  Future<void> _acceptRequest(UserModel user, int index) async {
    user.userStatus = UserStatus.active;
    await widget.userService.saveUser(user);
    setState(() {
      _pendingUsers.removeAt(index);
    });
  }

  Future<void> _declineRequest(UserModel user, int index) async {
    user.userStatus = UserStatus.removed;
    await widget.userService.saveUser(user);
    setState(() {
      _pendingUsers.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRequests();
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
                  child: _buildRequestsList(),
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
              'User requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildRequestsList() {
    if (_isRequestsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_isRequestsLoading && _pendingUsers.isEmpty) {
      return const Center(
        child: Text('No requests found'),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _pendingUsers.length,
      itemBuilder: (context, index) {
        final user = _pendingUsers[index];
        return _buildRequestTile(user, index);
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
    );
  }

  Widget _buildRequestTile(UserModel user, int index) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            user.email,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          user.userType == UserType.student ? 'Student' : 'Admin',
          style: TextStyle(
            fontSize: 16,
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // prevents overflow
        children: [
          SizedBox(
            width: 18,
          ),
          TextButton(
            onPressed: () {
              _acceptRequest(user, index);
            },
            style: TextButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text("Accept"),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _declineRequest(user, index);
            },
          ),
        ],
      ),
    );
  }
}
