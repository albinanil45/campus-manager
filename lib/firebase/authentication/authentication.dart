import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authentication {
  Future<bool> isUserLoggedIn() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user == null) {
        return false; // User is not logged in
      }

      // Refresh the user to check if they are disabled
      await user.reload();
      user = auth.currentUser; // Get updated user data

      if (user == null) {
        return false; // Either disabled or email not verified
      }

      return true; // User is logged in and active
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  Future<String> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid ?? "error"; // Return UID if successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "exists"; // User already registered
      } else {
        return "error"; // Generic error case
      }
    }
  }

  Future<String> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Login successful, return UID
      return userCredential.user?.uid ?? 'Unknown UID';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'user-not-found';
      } else if (e.code == 'wrong-password') {
        return 'wrong-password';
      } else if (e.code == 'user-disabled') {
        return 'user-disabled';
      } else {
        return 'error';
      }
    } catch (e) {
      // Catch-all for other errors
      return 'error';
    }
  }

  Future<String?> getLoggedInUserUid() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        return user.uid; // Return the user's UID if logged in
      } else {
        return null; // No user is logged in
      }
    } catch (e) {
      print('Error fetching UID: $e');
      return null; // Return null in case of an error
    }
  }

  Future<bool> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true; // Successfully logged out
    } catch (e) {
      print("Error logging out: $e");
      return false; // Logout failed
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true; // Email sent successfully
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }

  Future<void> sendVerificationEmail(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification email sent. Please verify before continuing.'
          ),
        )
      );
      await user.sendEmailVerification();
    }
  }

  Future<bool> waitForEmailVerification({int timeoutSeconds = 60}) async {
    User? user = FirebaseAuth.instance.currentUser;
    int elapsed = 0;
    while (elapsed < timeoutSeconds) {
      await Future.delayed(const Duration(seconds: 3));
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        return true;
      }
      elapsed += 3;
    }
    return false;
  }
}
