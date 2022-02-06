import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedBlur extends StatefulWidget {
  const AnimatedBlur({required this.duration, required this.delay, Key? key})
      : super(key: key);
  final Duration duration;
  final Duration delay;

  @override
  _AnimatedBlurState createState() => _AnimatedBlurState();
}

class _AnimatedBlurState extends State<AnimatedBlur>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () {
      animate();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void animate() {
    if (animationController.isCompleted) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        animate();
        return true;
      },
      child: AnimatedBuilder(
        child: Container(color: Colors.transparent),
        animation: animationController,
        builder: (context, child) {
          var value = animationController.value;
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: value * 10, sigmaY: value * 10),
            child: child,
          );
        },
      ),
    );
  }
}

class AnimatedEntry extends StatefulWidget {
  const AnimatedEntry(
      {required this.child,
      required this.duration,
      required this.delay,
      Key? key})
      : super(key: key);
  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  _AnimatedEntryState createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry>
    with SingleTickerProviderStateMixin {
  bool animationEnded = false;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () => animate());
  }

  void animate() {
    if (animationController.isCompleted || animationController.isAnimating) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        animate();
        return true;
      },
      child: SizeTransition(
          sizeFactor: animationController,
          axis: Axis.vertical,
          child: widget.child),
    );
  }
}

class MySmallMaterialButton extends StatefulWidget {
  const MySmallMaterialButton(this.onPressed, this.backgroundColor, this.child,
      {Key? key})
      : super(key: key);
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget child;

  @override
  _MySmallMaterialButtonState createState() => _MySmallMaterialButtonState();
}

class _MySmallMaterialButtonState extends State<MySmallMaterialButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
            height: 20,
            width: 20,
            child: GestureDetector(
                onTap: () => widget.onPressed.call(),
                child: FittedBox(child: widget.child))));
  }
}

class MyMaterialButton extends StatefulWidget {
  const MyMaterialButton(
      this.onPressed, this.backgroundColor, this.icon, this.iconColor,
      {Key? key})
      : super(key: key);
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  _MyMaterialButtonState createState() => _MyMaterialButtonState();
}

class _MyMaterialButtonState extends State<MyMaterialButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
          height: 35,
          width: 35,
          child: InkWell(
              radius: 17.5,
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                widget.onPressed.call();
              },
              child: Icon(
                widget.icon,
                color: widget.iconColor,
              ))),
    );
  }
}
