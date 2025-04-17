import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final  lightTheme = ThemeData(
  scaffoldBackgroundColor: whiteColor,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
    shape: CircleBorder()
  ),
  textTheme: GoogleFonts.poppinsTextTheme(),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      )
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    insetPadding: EdgeInsets.all(20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10)
    )
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: primaryColor
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 12
    ),
    suffixIconColor: greyColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5)
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: primaryColor,width: 2)
    ),
    hintStyle: GoogleFonts.poppins(
      color: greyColor,
      fontSize: 14
    ),
    labelStyle: GoogleFonts.poppins(),
    floatingLabelStyle: GoogleFonts.poppins(
      color: primaryColor
    )
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(primaryColor),
      textStyle: WidgetStatePropertyAll(
        GoogleFonts.poppins(
          fontWeight: FontWeight.w500
        )
      )
    )
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: GoogleFonts.poppins(color: greyColor,fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5)
      )
    )
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: primaryColor
  )
); 
