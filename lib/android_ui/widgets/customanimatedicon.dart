import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class CustomAnimatedIcon extends StatefulWidget {
  const CustomAnimatedIcon(
      {Key? key, required this.animatedIconData, required this.start})
      : super(key: key);
  final AnimatedIconData animatedIconData;
  final bool start;

  @override
  State<CustomAnimatedIcon> createState() => _CustomAnimatedIconState();
}

class _CustomAnimatedIconState extends State<CustomAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
  }

  @override
  void didUpdateWidget(covariant CustomAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.start) {
      setState(() {
        animationController.forward();
      });
    } else {
      setState(() {
        animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
        icon: widget.animatedIconData, progress: animationController);
  }
}
