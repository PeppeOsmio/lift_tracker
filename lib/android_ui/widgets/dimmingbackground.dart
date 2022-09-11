import 'dart:ui';

import 'package:flutter/material.dart';

class DimmingBackground extends StatefulWidget {
  const DimmingBackground(
      {required this.duration,
      required this.maxAlpha,
      this.blurred = false,
      Key? key})
      : super(key: key);
  final Duration duration;
  final int maxAlpha;
  final bool blurred;

  @override
  State<DimmingBackground> createState() => _DimmingBackgroundState();
}

class _DimmingBackgroundState extends State<DimmingBackground> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          setState(() {
            opacity = 0;
          });
          return true;
        },
        child: AnimatedOpacity(
            duration: widget.duration,
            opacity: opacity,
            child: widget.blurred
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withAlpha(widget.maxAlpha),
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black.withAlpha(widget.maxAlpha + 80),
                  )));
  }
}
