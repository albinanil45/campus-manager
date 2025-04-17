class Validators {
  bool verifyEmail(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool verifyMobileNumber(String number) {
    final RegExp mobileRegex = RegExp(r'^\d{10}$');
    return mobileRegex.hasMatch(number);
  }

  bool verifyPasswordStrength(String password) {
    final RegExp strongPasswordRegex =
        RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return strongPasswordRegex.hasMatch(password);
  }
}
