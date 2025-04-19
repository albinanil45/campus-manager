import 'dart:async';
import 'package:campus_manager/firebase/admin_service/admin_service.dart';
import 'package:campus_manager/firebase/announcement_service/announcement_service.dart';
import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/admin_department_model.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/otp_service/otp_service.dart';
import 'package:campus_manager/screens/admin_login_screen.dart';
import 'package:campus_manager/screens/home_screen.dart';
import 'package:campus_manager/screens/student_or_admin_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/validators/validators.dart';
import 'package:campus_manager/widgets/enter_otp_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class AdminSignupScreen extends StatefulWidget {
  final AdminService adminService;
  final UserService userService;
  final EnterOtpPopup enterOtpPopup;
  final Validators validators;
  final InstitutionModel institution;
  final Authentication authentication;
  const AdminSignupScreen(
      {super.key,
      required this.institution,
      required this.validators,
      required this.enterOtpPopup,
      required this.authentication,
      required this.userService,
      required this.adminService});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  ValueNotifier<String?> selectedDepartment = ValueNotifier<String?>(null);
  ValueNotifier<bool> obscure = ValueNotifier<bool>(true);
  ValueNotifier<bool> confirmObscure = ValueNotifier<bool>(true);
  ValueNotifier<bool> adminPasscodeObscure = ValueNotifier<bool>(true);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController institutionIdController = TextEditingController();
  TextEditingController adminPasscodeController = TextEditingController();

  late final List<String> _departments;

  @override
  void initState() {
    _departments = widget.institution.departments;
    super.initState();
  }

  @override
  void dispose() {
    selectedDepartment.value = null;
    super.dispose();
  }

  Future<void> signupAdmin() async {
    // Validate required text fields
    List<TextEditingController> controllers = [
      nameController,
      emailController,
      phoneController,
      passwordController,
      confirmPasswordController,
      institutionIdController,
      adminPasscodeController
    ];

    for (var controller in controllers) {
      if (controller.text.trim().isEmpty) {
        showError('All fields are required');
        return;
      }
    }

    // Validate selected department
    if (selectedDepartment.value == null) {
      showError('Please select a department');
      return;
    }

    // Validate email format
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

    // Check institution ID & admin passcode
    if (widget.institution.id != institutionIdController.text.trim() ||
        widget.institution.adminPasscode !=
            adminPasscodeController.text.trim()) {
      showError('Incorrect institution ID or admin passcode');
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

    // Successfully signed up, proceed with storing user data
    UserModel user = UserModel(
      id: uid,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      userType: UserType.admin,
      createdAt: Timestamp.now(),
    );

    AdminDepartmentModel departmentModel = AdminDepartmentModel(
        adminId: uid, department: selectedDepartment.value!);

    bool isUserStored = await widget.userService.saveUser(user);
    bool isDepartmentStored =
        await widget.adminService.saveAdminDepartment(departmentModel);
    if (!isUserStored || !isDepartmentStored) {
      showError('Failed to sign up');
      isLoading.value = false;
      await widget.authentication.logoutUser();
      return;
    }

    // Navigate to home screen
    isLoading.value = false;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => HomeScreen(
              userService: UserService(),
              announcementService: AnnouncementService(),
                  specialRoleModel: null,
                  studentCourseModel: null,
                  departmentModel: departmentModel,
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
                            'ADMIN SIGNUP',
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
                            decoration:
                                const InputDecoration(hintText: 'Enter name'),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(hintText: 'Enter email'),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                hintText: 'Enter phone number'),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder(
                            valueListenable: selectedDepartment,
                            builder: (context, value, child) {
                              return DropdownButtonFormField<String>(
                                borderRadius: BorderRadius.circular(10),
                                dropdownColor: whiteColor,
                                value: value,
                                hint: const Text(
                                  'Choose Department',
                                  style:
                                      TextStyle(color: greyColor, fontSize: 14),
                                ),
                                onChanged: (String? newValue) {
                                  selectedDepartment.value = newValue;
                                },
                                items: _departments.map((String department) {
                                  return DropdownMenuItem<String>(
                                    value: department,
                                    child: Text(department),
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
                                    icon: Icon(
                                      value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
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
                                      confirmObscure.value =
                                          !confirmObscure.value;
                                    },
                                    icon: Icon(
                                      value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
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
                                hintText: 'Enter institution ID'),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder(
                            valueListenable: adminPasscodeObscure,
                            builder: (context, value, child) {
                              return TextField(
                                controller: adminPasscodeController,
                                obscureText: value,
                                decoration: InputDecoration(
                                  hintText: 'Enter admin passcode',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      adminPasscodeObscure.value =
                                          !adminPasscodeObscure.value;
                                    },
                                    icon: Icon(
                                      value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 25),
                          ValueListenableBuilder(
                            valueListenable: isLoading,
                            builder: (context, value, child) {
                              return ElevatedButton(
                                onPressed: value ? null : signupAdmin,
                                child: value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: whiteColor,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'SIGN UP',
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 20,
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
                                      childCurrent: StudentOrAdminScreen(
                                        institution: widget.institution,
                                      ),
                                      child: AdminLoginScreen(
                                        adminService: AdminService(),
                                        userService: UserService(),
                                        authentication: Authentication(),
                                        enterOtpPopup: EnterOtpPopup(
                                          otpService: OtpService(),
                                        ),
                                        validators: Validators(),
                                        institution: widget.institution,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Sign In'),
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
