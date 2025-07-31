import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class OtpService {
  String generateOtp() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

// Method to send OTP to an email using mailer package
  Future<String> sendOtpEmail(String recipientEmail) async {
    String otp = generateOtp();

    String username = 'albinanilkumar45@gmail.com';
    String password = 'vjmb gjkw hjuh pcdn';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Campus Manager')
      ..recipients.add(recipientEmail)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: $otp';

    try {
      await send(message, smtpServer);
      // ignore: empty_catches
    } catch (e) {}

    return otp;
  }
}
