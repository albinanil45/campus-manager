import 'package:campus_manager/otp_service/otp_service.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class EnterOtpPopup {
  final OtpService otpService;
  EnterOtpPopup({required this.otpService});

  Future<bool> showOtpPopup(BuildContext context, String email) async {
    final otp = await otpService.sendOtpEmail(email);
    return await showDialog<bool>(
          context: context,
          builder: (context) => EnterOtpPopupDialog(otpService: otpService,email: email,otp: otp,),
        ) ??
        false;
  }
}

class EnterOtpPopupDialog extends StatefulWidget {
  final String email;
  final String otp;
  final OtpService otpService;
  const EnterOtpPopupDialog({super.key, required this.otpService, required this.email, required this.otp});

  @override
  _EnterOtpPopupDialogState createState() => _EnterOtpPopupDialogState();
}

class _EnterOtpPopupDialogState extends State<EnterOtpPopupDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text(
        'Enter OTP',
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'An OTP has been sent to your email',
              style: TextStyle(
                color: blackColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            Pinput(
              onCompleted: (value) {
                if (widget.otp == value) {
                  Navigator.of(context).pop(true); // Return true on success
                }
              },
              length: 6,
              focusedPinTheme: PinTheme(
                height: 45,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              defaultPinTheme: PinTheme(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
