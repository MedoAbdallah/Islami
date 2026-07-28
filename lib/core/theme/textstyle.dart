import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_colors.dart';

class TextStylesHelper {
  static TextStyle largeTitleTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w900,
      fontSize: 24,
      fontFamily: "Janna",
    );
  }

    static TextStyle largeFontTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w900,
      fontSize: 30,
      fontFamily: "Janna",
    );
  }

  static TextStyle mediumTitleTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w900,
      fontSize: 22,
      fontFamily: "Janna",
    );
  }

  static TextStyle smallTitleTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w900,
      fontSize: 20,
      fontFamily: "Janna",
    );
  }

   static TextStyle smallTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: 19,
      fontFamily: "Janna",
    );
  }


  static TextStyle largeLabelTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w900,
      fontSize: 21,
      fontFamily: "Janna",
    );
  }

    static TextStyle largeLabelBoldTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      fontFamily: "Janna",
    );
  }

  static TextStyle largeTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w900,
      fontSize: 19,
      fontFamily: "Janna",
    );
  }

   static TextStyle largeBoldTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: 16,
      fontFamily: "Janna",
    );
  }



  static TextStyle mediumLabelTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w800,
      fontSize: 16,
      fontFamily: "Janna",
    );
  }

  static TextStyle smallLabelTextStyle({Color textColor = AppColors.gold}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w900,
      fontSize: 15,
      fontFamily: "Janna",
    );
  }

  static TextStyle largeBodyTextStyle({Color textColor = AppColors.white}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      fontFamily: "Janna",
    );
  }

  static TextStyle mediumBodyTextStyle({Color textColor = AppColors.white}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      fontFamily: "Janna",
    );
  }

  static TextStyle smallBodyTextStyle({Color textColor = AppColors.white}) {
    return TextStyle(
      color: textColor,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      fontFamily: "Janna",
    );
  }
}
