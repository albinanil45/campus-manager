import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';

class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({super.key});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {

  @override
  void initState() {
    showMessage();
    super.initState();
  }

  Future<void> showMessage () async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('An otp has been sent to your email'),
      )
    );
  } 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'ENTER OTP',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20,),
              const TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Enter otp'),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'VERIFY',
                  style: TextStyle(color: whiteColor, fontSize: 20),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
