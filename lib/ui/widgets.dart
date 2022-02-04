import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedEntry extends StatefulWidget {
  const AnimatedEntry({required this.child, Key? key}) : super(key: key);
  final Widget child;

  @override
  _AnimatedEntryState createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry> {
  bool animationEnded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        animationEnded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        duration: const Duration(milliseconds: 100),
        child: animationEnded
            ? widget.child
            : SizedBox(
                height: 0,
              ));
  }
}

class HighlitedMenu extends StatefulWidget {
  const HighlitedMenu(this.child, this.onRemove, this.onCancel, {Key? key})
      : super(key: key);
  final StatefulWidget child;
  final VoidCallback onCancel;
  final VoidCallback onRemove;

  @override
  _HighlitedMenuState createState() => _HighlitedMenuState();
}

class _HighlitedMenuState extends State<HighlitedMenu> {
  @override
  Widget build(BuildContext context) {
    widget.child.key;
    return GestureDetector(
      child: widget.child,
      onLongPress: () {
        Navigator.push(
            context,
            PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, a1, a2) {
                  print(widget.child.key);
                  return SafeArea(
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Stack(
                        alignment: AlignmentDirectional.center,
                        fit: StackFit.expand,
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(color: Colors.transparent),
                          ),
                          Positioned(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Center(child: widget.child),
                          )),
                        ],
                      ),
                    ),
                  );
                }));
      },
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
