import 'package:campus_manager/firebase/admin_service/admin_service.dart';
import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/firebase/institution_service/institution_service.dart';
import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/admin_department_model.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/models/student_course_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/screens/home_screen.dart';
import 'package:campus_manager/screens/student_or_admin_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final StudentService studentService;
  final AdminService adminService;
  final InstitutionService institutionService;
  final Authentication authentication;
  final UserService userService;
  const SplashScreen({super.key, required this.institutionService, required this.authentication, required this.userService, required this.adminService, required this.studentService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late final InstitutionModel institution;
  AdminDepartmentModel? departmentModel;
  StudentCourseModel? courseModel;

  @override
  void initState() {
    fetchInstitutionAndCheckLogin();
    super.initState();
  }

  Future<void> fetchInstitutionAndCheckLogin () async {
    institution = (await widget.institutionService.fetchInstitutionDetails())!;
    bool isLoggedIn = await widget.authentication.isUserLoggedIn();
    if(isLoggedIn){
      final uid = await widget.authentication.getLoggedInUserUid();
      final user = await widget.userService.getUser(uid!);
      if(user!.userType == UserType.admin){
        departmentModel = await widget.adminService.getAdminDepartment(uid);
      } else if (user.userType == UserType.student){
        courseModel = await widget.studentService.getStudentCourse(uid);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: user,
            institution: institution,
            authentication: Authentication(),
            departmentModel: departmentModel,
            studentCourseModel: courseModel,
          ),
        )
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => StudentOrAdminScreen(
            institution: institution,
          ),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Stack(
        children: [
          Center(
            child: Text(
              'Campus Manager',
              style: TextStyle(
                color: primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            bottom: 60, 
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
