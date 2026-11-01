import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

/// All styles now take a [BuildContext] so colors follow the active theme.
/// Styles that used to default to gold now use `palette.primary`;
/// styles that defaulted to white now use `palette.onBackground`.
class TextStylesHelper {
  static TextStyle _title(
      BuildContext context,
      Color? textColor, {
        required FontWeight weight,
        required double size,
      }) {
    return TextStyle(
      color: textColor ?? context.palette.primary,
      fontWeight: weight,
      fontSize: size,
      fontFamily: "Janna",
    );
  }

  static TextStyle _body(
      BuildContext context,
      Color? textColor, {
        required double size,
      }) {
    return TextStyle(
      color: textColor ?? context.palette.onBackground,
      fontWeight: FontWeight.w500,
      fontSize: size,
      fontFamily: "Janna",
    );
  }

  // ---------- Accent styles (primary by default) ----------

  static TextStyle largeTitleTextStyle(BuildContext context,
      {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.w900, size: 24);

  static TextStyle largeFontTextStyle(BuildContext context,
      {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.w900, size: 30);

  static TextStyle mediumTitleTextStyle(BuildContext context,
      {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.w900, size: 22);

  static TextStyle smallTitleTextStyle(BuildContext context,
      {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.w900, size: 20);

  static TextStyle smallTextStyle(BuildContext context, {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.bold, size: 19);

  static TextStyle largeLabelTextStyle(BuildContext context,
      {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.w900, size: 21);

  static TextStyle largeLabelBoldTextStyle(BuildContext context,
      {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.bold, size: 20);

  static TextStyle largeTextStyle(BuildContext context, {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.w900, size: 19);

  static TextStyle largeBoldTextStyle(BuildContext context,
      {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.bold, size: 16);

  static TextStyle mediumLabelTextStyle(BuildContext context,
      {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.w800, size: 16);

  static TextStyle smallLabelTextStyle(BuildContext context,
      {Color? textColor}) =>
      _title(context, textColor, weight: FontWeight.w900, size: 15);

  // ---------- Body styles (onBackground by default) ----------

  static TextStyle largeBodyTextStyle(BuildContext context,
      {Color? textColor}) =>
      _body(context, textColor, size: 16);

  static TextStyle mediumBodyTextStyle(BuildContext context,
      {Color? textColor}) =>
      _body(context, textColor, size: 14);

  static TextStyle smallBodyTextStyle(BuildContext context,
      {Color? textColor}) =>
      _body(context, textColor, size: 12);
}