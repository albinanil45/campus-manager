import 'package:campus_manager/firebase/admin_service/admin_service.dart';
import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/firebase/institution_service/institution_service.dart';
import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/helpers/check_internet.dart';
import 'package:campus_manager/models/admin_department_model.dart';
import 'package:campus_manager/models/special_role_model.dart';
import 'package:campus_manager/models/student_course_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/screens/home_screen.dart';
import 'package:campus_manager/screens/no_internet_screen.dart';
import 'package:campus_manager/screens/student_or_admin_screen.dart';
import 'package:flutter/material.dart';

class GetInitialScreen {
  static Future<Widget> getInitialScreen() async {
    bool isInternetConnected = await CheckInternet.isInternetAvailable();

    if (!isInternetConnected) {
      return NoInternetScreen();
    } else {
      // Services
      final institutionService = InstitutionService();
      final authentication = Authentication();
      final userService = UserService();
      final adminService = AdminService();
      final studentService = StudentService();

      final institution = await institutionService.fetchInstitutionDetails();

      bool isLoggedIn = await authentication.isUserLoggedIn();

      if (isLoggedIn) {
        final uid = await authentication.getLoggedInUserUid();
        final user = await userService.getUser(uid!);

        AdminDepartmentModel? departmentModel;
        SpecialRoleModel? specialRoleModel;
        StudentCourseModel? courseModel;

        if (user!.userType == UserType.admin) {
          departmentModel = await adminService.getAdminDepartment(uid);
          specialRoleModel = await adminService.getSpecialRole(uid);
        } else if (user.userType == UserType.student) {
          courseModel = await studentService.getStudentCourse(uid);
        }

        return HomeScreen(
          user: user,
          institution: institution!,
          authentication: authentication,
          departmentModel: departmentModel,
          specialRoleModel: specialRoleModel,
          studentCourseModel: courseModel,
        );
      } else {
        return StudentOrAdminScreen(
          institution: institution!,
        );
      }
    }
  }
}
