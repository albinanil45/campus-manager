import 'package:campus_manager/firebase_options.dart';
import 'package:campus_manager/helpers/get_initial_screen.dart';
import 'package:campus_manager/themes/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Widget initialScreen = await GetInitialScreen.getInitialScreen();

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Manager',
      theme: lightTheme,
      home: initialScreen,
    );
  }
}
