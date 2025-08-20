import 'package:campus_manager/firebase/admin_service/admin_service.dart';
import 'package:campus_manager/firebase/announcement_service/announcement_service.dart';
import 'package:campus_manager/firebase/authentication/authentication.dart';
import 'package:campus_manager/firebase/user_service/user_service.dart';
import 'package:campus_manager/models/institution_model.dart';
import 'package:campus_manager/models/user_model.dart';
import 'package:campus_manager/otp_service/otp_service.dart';
import 'package:campus_manager/screens/admin_signup_screen.dart';
import 'package:campus_manager/screens/home_screen.dart';
import 'package:campus_manager/screens/pending_or_removed_screen.dart';
import 'package:campus_manager/screens/student_or_admin_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:campus_manager/validators/validators.dart';
import 'package:campus_manager/widgets/enter_otp_popup.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class AdminLoginScreen extends StatefulWidget {
  final AdminService adminService;
  final UserService userService;
  final EnterOtpPopup enterOtpPopup;
  final InstitutionModel institution;
  final Validators validators;
  final Authentication authentication;
  const AdminLoginScreen(
      {super.key,
      required this.institution,
      required this.validators,
      required this.enterOtpPopup,
      required this.authentication,
      required this.userService,
      required this.adminService});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  ValueNotifier<bool> obscure = ValueNotifier<bool>(true);
  ValueNotifier<bool> adminPasscodeObscure = ValueNotifier<bool>(true);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController institutionIdController = TextEditingController();
  TextEditingController adminPasscodeController = TextEditingController();

  Future<void> loginAdmin() async {
    List<TextEditingController> controllers = [
      emailController,
      passwordController,
      institutionIdController,
      adminPasscodeController
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

    if (widget.institution.id != institutionIdController.text.trim() ||
        widget.institution.adminPasscode !=
            adminPasscodeController.text.trim()) {
      showError('Incorrect institution ID or admin passcode');
      return;
    }

    isLoading.value = true;
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

    final user = await widget.userService.getUser(uid);
    final departmentModel = await widget.adminService.getAdminDepartment(uid);
    final specialRoleModel = await widget.adminService.getSpecialRole(uid);

    isLoading.value = false;

    if (user!.userStatus == UserStatus.pending) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  const PendingOrRemovedScreen(isPending: true)),
          (Route<dynamic> route) => false);
    } else if (user.userStatus == UserStatus.removed) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  const PendingOrRemovedScreen(isPending: false)),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    announcementService: AnnouncementService(),
                    userService: UserService(),
                    studentCourseModel: null,
                    departmentModel: departmentModel,
                    specialRoleModel: specialRoleModel,
                    user: user,
                    authentication: Authentication(),
                    institution: widget.institution,
                  )),
          (Route<dynamic> route) => false);
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      showError('Please fill the email field');
      return;
    }
    if (!widget.validators.verifyEmail(emailController.text.trim())) {
      showError('Please enter a valid email');
      return;
    }

    bool isResetLinkSend = await widget.authentication
        .sendPasswordResetEmail(emailController.text.trim());
    if (!isResetLinkSend) {
      showError('An error occured');
      return;
    }
    showError('A link to reset your password has been sent to your email');
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
                          const Text(
                            'ADMIN LOGIN',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(hintText: 'Enter email'),
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
                          TextButton(
                            onPressed: resetPassword,
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: isLoading,
                            builder: (context, value, child) {
                              return ElevatedButton(
                                onPressed: value ? null : loginAdmin,
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
                                        'SIGN IN',
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
                                'Don\'t have an account?',
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
                                      child: AdminSignupScreen(
                                        adminService: AdminService(),
                                        userService: UserService(),
                                        authentication: Authentication(),
                                        enterOtpPopup: EnterOtpPopup(
                                          otpService: OtpService(),
                                        ),
                                        institution: widget.institution,
                                        validators: Validators(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
