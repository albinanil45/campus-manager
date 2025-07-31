import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

final lightTheme = ThemeData(
    scaffoldBackgroundColor: whiteColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor, shape: CircleBorder()),
    fontFamily: 'TitilliumWeb',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
    ),
    snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: primaryColor),
    inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        suffixIconColor: greyColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: primaryColor, width: 2)),
        hintStyle: const TextStyle(color: greyColor, fontSize: 14),
        labelStyle: const TextStyle(color: greyColor),
        floatingLabelStyle: const TextStyle(color: primaryColor)),
    textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(primaryColor),
    )),
    dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
            hintStyle: const TextStyle(color: greyColor, fontSize: 14),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5)))),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: primaryColor));
