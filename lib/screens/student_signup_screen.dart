import 'package:campus_manager/firebase/announcement_service/announcement_service.dart';
import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/firebase/student_service/student_service.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/models/student_course_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/otp_service/otp_service.dart';
import 'package:campus_manager/screens/home_screen.dart';
import 'package:campus_manager/screens/student_login_screen.dart';
import 'package:campus_manager/screens/student_or_admin_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/validators/validators.dart';
import 'package:campus_manager/widgets/enter_otp_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class StudentSignupScreen extends StatefulWidget {
  final UserService userService;
  final StudentService studentService;
  final Authentication authentication;
  final EnterOtpPopup enterOtpPopup;
  final Validators validators;
  final InstitutionModel institution;
  const StudentSignupScreen(
      {super.key,
      required this.institution,
      required this.validators,
      required this.enterOtpPopup,
      required this.authentication,
      required this.userService,
      required this.studentService});

  @override
  State<StudentSignupScreen> createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  ValueNotifier<String?> selectedCourse = ValueNotifier<String?>(null);
  ValueNotifier<String?> selectedSemester = ValueNotifier<String?>(null);
  ValueNotifier<bool> obscure = ValueNotifier<bool>(true);
  ValueNotifier<bool> confirmObscure = ValueNotifier<bool>(true);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController institutionIdController = TextEditingController();
  late final List<String> _courses;
  final List<String> _semesters = ['1', '2', '3', '4', '5', '6'];

  @override
  void initState() {
    _courses = widget.institution.courses;
    super.initState();
  }

  @override
  void dispose() {
    selectedCourse.value = null;
    selectedSemester.value = null;
    super.dispose();
  }

  Future<void> signupStudent() async {
    List<TextEditingController> controllers = [
      nameController,
      emailController,
      phoneController,
      passwordController,
      confirmPasswordController,
      institutionIdController,
    ];

    for (var controller in controllers) {
      if (controller.text.trim().isEmpty) {
        showError('All fields are required');
        return;
      }
    }

    if (selectedCourse.value == null) {
      showError('Please select your course');
      return;
    }

    if (selectedSemester.value == null) {
      showError('Please select your semester');
      return;
    }

    if (!widget.validators.verifyEmail(emailController.text.trim())) {
      showError('Enter a valid email');
      return;
    }

    // Validate phone number format
    if (!widget.validators.verifyMobileNumber(phoneController.text.trim())) {
      showError('Enter a valid phone number');
      return;
    }

    // Password matching validation
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      showError('Both password and confirm password must be the same');
      return;
    }

    // Password strength validation
    if (!widget.validators
        .verifyPasswordStrength(passwordController.text.trim())) {
      showError(
          'Password must contain at least 8 characters including letters, numbers, and special characters');
      return;
    }

    if (widget.institution.id != institutionIdController.text.trim()) {
      showError('Incorrect institution ID');
      return;
    }

    // Send verification email
    isLoading.value = true;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String uid = await widget.authentication.signUpWithEmail(email, password);

    if (uid == 'exists') {
      showError('User already exists, try signing in');
      isLoading.value = false;
      return;
    } else if (uid == 'error') {
      showError('Failed to sign up');
      isLoading.value = false;
      return;
    }

     // Send verification email
    await widget.authentication.sendVerificationEmail(context);

    // Poll for verification
    bool isVerified = await widget.authentication.waitForEmailVerification();
    if (!isVerified) {
      showError('Email not verified. Please check your inbox and try again.');
      await widget.authentication.logoutUser();
      isLoading.value = false;
      return;
    }
    
    UserModel user = UserModel(
      id: uid,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      userType: UserType.student,
      createdAt: Timestamp.now(),
    );

    StudentCourseModel studentCourse = StudentCourseModel(
        studentId: uid,
        course: selectedCourse.value!,
        semester: selectedSemester.value!);

    bool isUserStored = await widget.userService.saveUser(user);
    bool isCourseStored =
        await widget.studentService.saveStudentCourse(studentCourse);

    if (!isUserStored || !isCourseStored) {
      showError('Failed to sign up');
      isLoading.value = false;
      await widget.authentication.logoutUser();
      return;
    }

    isLoading.value = false;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => HomeScreen(
              announcementService: AnnouncementService(),
                  studentCourseModel: studentCourse,
                  specialRoleModel: null,
                  departmentModel: null,
                  user: user,
                  authentication: Authentication(),
                  institution: widget.institution,
                )),
        (Route<dynamic> route) => false);
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
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // vertically center
                      crossAxisAlignment: CrossAxisAlignment.center, // horizontally center
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'STUDENT SIGNUP',
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(hintText: 'Enter name'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(hintText: 'Enter email'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(hintText: 'Enter phone number'),
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder(
                          valueListenable: selectedCourse,
                          builder: (context, value, child) {
                            return DropdownButtonFormField<String>(
                              borderRadius: BorderRadius.circular(10),
                              dropdownColor: whiteColor,
                              value: value,
                              hint: const Text(
                                'Choose Course',
                                style: TextStyle(color: greyColor, fontSize: 14),
                              ),
                              onChanged: (String? newValue) {
                                selectedCourse.value = newValue;
                              },
                              items: _courses.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder(
                          valueListenable: selectedSemester,
                          builder: (context, value, child) {
                            return DropdownButtonFormField<String>(
                              borderRadius: BorderRadius.circular(10),
                              dropdownColor: whiteColor,
                              value: value,
                              hint: const Text(
                                'Choose Semester',
                                style: TextStyle(color: greyColor, fontSize: 14),
                              ),
                              onChanged: (String? newValue) {
                                selectedSemester.value = newValue;
                              },
                              items: _semesters.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            );
                          },
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
                                  icon: Icon(value ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder(
                          valueListenable: confirmObscure,
                          builder: (context, value, child) {
                            return TextField(
                              controller: confirmPasswordController,
                              obscureText: value,
                              decoration: InputDecoration(
                                hintText: 'Confirm password',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    confirmObscure.value = !confirmObscure.value;
                                  },
                                  icon: Icon(value ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: institutionIdController,
                          decoration: const InputDecoration(hintText: 'Enter institution ID'),
                        ),
                        const SizedBox(height: 25),
                        ValueListenableBuilder(
                          valueListenable: isLoading,
                          builder: (context, value, child) {
                            return ElevatedButton(
                              onPressed: isLoading.value ? null : signupStudent,
                              child: !isLoading.value
                                  ? const Text(
                                      'SIGN UP',
                                      style: TextStyle(color: whiteColor, fontSize: 20),
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
                              'Already have an account ?',
                              style: TextStyle(color: blackColor),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    childCurrent: StudentOrAdminScreen(institution: widget.institution),
                                    child: StudentLoginScreen(
                                      validators: Validators(),
                                      enterOtpPopup: EnterOtpPopup(otpService: OtpService()),
                                      authentication: Authentication(),
                                      userService: UserService(),
                                      studentService: StudentService(),
                                      institution: widget.institution,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Sign In'),
                            )
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
