import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/otp_service/otp_service.dart';
import 'package:campus_manager/screens/home_screen.dart';
import 'package:campus_manager/screens/student_or_admin_screen.dart';
import 'package:campus_manager/screens/student_signup_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/validators/validators.dart';
import 'package:campus_manager/widgets/enter_otp_popup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class StudentLoginScreen extends StatefulWidget {
  final Validators validators;
  final EnterOtpPopup enterOtpPopup;
  final Authentication authentication;
  final UserService userService;
  final StudentService studentService;
  final InstitutionModel institution;
  const StudentLoginScreen(
      {super.key,
      required this.institution,
      required this.validators,
      required this.enterOtpPopup,
      required this.authentication,
      required this.userService,
      required this.studentService});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  ValueNotifier<bool> obscure = ValueNotifier<bool>(true);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController institutionIdController = TextEditingController();

  Future<void> loginStudent() async {
    List<TextEditingController> controllers = [
      emailController,
      passwordController,
      institutionIdController,
    ];

    for (var controller in controllers) {
      if (controller.text.trim().isEmpty) {
        showError('All fields are required');
        return;
      }
    }
    if (!widget.validators.verifyEmail(emailController.text.trim())) {
      showError('Enter a valid email');
      return;
    }
    if (widget.institution.id != institutionIdController.text.trim()) {
      showError('Institution ID is incorrect');
      return;
    }

    isLoading.value = true;
    bool isOtpVerified = await widget.enterOtpPopup
        .showOtpPopup(context, emailController.text.trim());
    if (!isOtpVerified) {
      isLoading.value = false;
      return;
    }

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    String uid = await widget.authentication.loginWithEmail(email, password);

    if (uid == 'user-not-found') {
      showError('No such a user exist');
      isLoading.value = false;
      return;
    } else if (uid == 'wrong-password') {
      showError('Password is wrong');
      isLoading.value = false;
      return;
    } else if (uid == 'user-disabled') {
      showError('This user is disabled');
      isLoading.value = false;
      return;
    } else if (uid == 'error') {
      showError('Failed to signin');
      isLoading.value = false;
      return;
    }

    final user = await widget.userService.getUser(uid);
    final courseModel = await widget.studentService.getStudentCourse(uid);

    isLoading.value = false;

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  studentCourseModel: courseModel,
                  departmentModel: null,
                  user: user!,
                  authentication: Authentication(),
                  institution: widget.institution,
                )),
        (Route<dynamic> route) => false);
  }

  Future<void> resetPassword () async {
    if(emailController.text.trim().isEmpty){
      showError(
        'Please fill the email field'
      );
      return;
    }
    if(!widget.validators.verifyEmail(emailController.text.trim())){
      showError(
        'Please enter a valid email'
      );
      return;
    }

    bool isResetLinkSend = await widget.authentication.sendPasswordResetEmail(emailController.text.trim());
    if(!isResetLinkSend){
      showError(
        'An error occured'
      );
      return;
    }
    showError(
      'A link to reset your password has been sent to your email'
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'STUDENT LOGIN',
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Enter email',
                          ),
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder(
                          valueListenable: obscure,
                          builder: (context, value, child) {
                            return TextField(
                              controller: passwordController,
                              obscureText: value,
                              decoration: InputDecoration(
                                hintText: 'Enter password',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    obscure.value = !obscure.value;
                                  },
                                  icon: Icon(
                                    value ? Icons.visibility_off : Icons.visibility,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: institutionIdController,
                          decoration: const InputDecoration(
                            hintText: 'Enter institution ID',
                          ),
                        ),
                        TextButton(
                          onPressed: resetPassword,
                          child: const Text('Forgot password?'),
                        ),
                        ValueListenableBuilder(
                          valueListenable: isLoading,
                          builder: (context, value, child) {
                            return ElevatedButton(
                              onPressed: value ? null : loginStudent,
                              child: !value
                                  ? const Text(
                                      'SIGN IN',
                                      style: TextStyle(
                                        color: whiteColor,
                                        fontSize: 20,
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: whiteColor,
                                        strokeWidth: 2,
                                      ),
                                    ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style: TextStyle(color: blackColor),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    childCurrent: StudentOrAdminScreen(institution: widget.institution),
                                    child: StudentSignupScreen(
                                      validators: Validators(),
                                      authentication: Authentication(),
                                      studentService: StudentService(),
                                      userService: UserService(),
                                      enterOtpPopup: EnterOtpPopup(otpService: OtpService()),
                                      institution: widget.institution,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

}
