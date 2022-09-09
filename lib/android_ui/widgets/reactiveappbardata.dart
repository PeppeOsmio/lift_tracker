import 'package:flutter/material.dart';

class ReactiveAppBarData {
  ReactiveAppBarData(
      this.isSelected, this.leading, this.title, this.actions, this.onUpdate);
  bool isSelected;
  Color? backgroundColor;
  Color? foregroundColor;
  Widget? leading;
  String? title;
  List<Widget> actions;
  VoidCallback? onUpdate;
}
