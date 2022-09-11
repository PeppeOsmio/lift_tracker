import 'package:flutter/material.dart';

class AppBarData {
  AppBarData(
      {this.leading,
      this.title,
      this.actions,
      this.onUpdate,
      this.backgroundColor,
      this.foregroundColor});
  Color? backgroundColor;
  Color? foregroundColor;
  Widget? leading;
  String? title;
  List<Widget>? actions;
  VoidCallback? onUpdate;
}
