import 'package:campus_manager/firebase/admin_service/admin_service.dart';
import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/otp_service/otp_service.dart';
import 'package:campus_manager/screens/admin_signup_screen.dart';
import 'package:campus_manager/screens/student_signup_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/validators/validators.dart';
import 'package:campus_manager/widgets/enter_otp_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';

class StudentOrAdminScreen extends StatelessWidget {
  final InstitutionModel institution;
  const StudentOrAdminScreen({super.key, required this.institution});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Breakpoint logic
    final bool isDesktop = screenWidth > 1000;
    final double maxContentWidth = isDesktop ? 500 : screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: const Icon(
          Icons.arrow_back,
          color: whiteColor,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    Center(
                      child: Image.asset(
                        'assets/icon/logo_index.png',
                        height: screenHeight * 0.08,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    SizedBox(
                      height: screenHeight * 0.45,
                      child: SvgPicture.asset(
                        'assets/classroom.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    // Student Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftJoined,
                              childCurrent: this,
                              child: StudentSignupScreen(
                                enterOtpPopup:
                                    EnterOtpPopup(otpService: OtpService()),
                                authentication: Authentication(),
                                userService: UserService(),
                                studentService: StudentService(),
                                validators: Validators(),
                                institution: institution,
                              ),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'I\'m a Student',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Admin Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftJoined,
                              childCurrent: this,
                              child: AdminSignupScreen(
                                adminService: AdminService(),
                                userService: UserService(),
                                authentication: Authentication(),
                                enterOtpPopup:
                                    EnterOtpPopup(otpService: OtpService()),
                                institution: institution,
                                validators: Validators(),
                              ),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'I\'m a Faculty Member',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
