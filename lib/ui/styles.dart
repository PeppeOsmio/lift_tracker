import 'package:flutter/material.dart';

class Palette {
  static Color orange = const Color.fromARGB(255, 255, 119, 51);
  static Color backgroundDark = const Color.fromARGB(255, 20, 20, 20);
  static Color elementsDark = const Color.fromARGB(255, 31, 31, 31);
  static Color lightGreyBlue = const Color.fromARGB(255, 57, 86, 101);
}

class Styles {
  static TextStyle style(
      {bool dark = true,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle}) {
    return TextStyle(
        color: dark ? Colors.white : Colors.black,
        fontSize: fontSize ?? 18,
        fontWeight: fontWeight,
        fontStyle: fontStyle);
  }
}
