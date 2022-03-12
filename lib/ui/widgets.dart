import 'dart:developer';
import 'dart:ui';
import 'package:curved_animation_controller/curved_animation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/helper.dart';
import 'colors.dart';

Future showDimmedBackgroundDialog(BuildContext context,
    {String? title,
    String? content,
    required String rightText,
    required String leftText,
    required Function rightOnPressed,
    required Function leftOnPressed,
    Function? barrierOnPressed}) async {
  Helper.unfocusTextFields(context);
  await showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (ctx) {
        return Stack(children: [
          GestureDetector(
              onTap: () {
                if (barrierOnPressed == null) {
                  Navigator.maybePop(context);
                  return;
                }
                barrierOnPressed();
              },
              child: const DimmingBackground(
                blurred: true,
                duration: Duration(milliseconds: 150),
                maxAlpha: 150,
              )),
          AlertDialog(
            backgroundColor: Palette.backgroundDark,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            title: title != null ? Text(title) : null,
            content: content != null
                ? Text(
                    content,
                    style: TextStyle(color: Colors.white),
                  )
                : null,
            actions: [
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Palette.elementsDark)),
                  onPressed: () {
                    leftOnPressed();
                  },
                  child: Text(leftText)),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Palette.elementsDark)),
                  onPressed: () {
                    rightOnPressed();
                  },
                  child: Text(rightText)),
            ],
          ),
        ]);
      });
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar(
      {required this.middleText,
      required this.onBack,
      required this.onSubmit,
      required this.backButton,
      required this.submitButton,
      Key? key})
      : super(key: key);
  final bool backButton;
  final bool submitButton;
  final String middleText;
  final Function onBack;
  final Function onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: [
          backButton
              ? Material(
                  color: Palette.elementsDark,
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                      height: 35,
                      width: 35,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            onBack();
                          },
                          child: const Icon(
                            Icons.chevron_left_outlined,
                            color: Colors.redAccent,
                          ))),
                )
              : SizedBox(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Text(
                middleText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          submitButton
              ? Material(
                  color: Palette.elementsDark,
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                      height: 35,
                      width: 35,
                      child: InkWell(
                          onTap: () {
                            onSubmit();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: const Icon(
                            Icons.check_outlined,
                            color: Colors.green,
                          ))),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: SizedBox(),
                )
        ],
      ),
    );
  }
}

class CardMenuButton extends StatelessWidget {
  const CardMenuButton(
      {required this.onPressed,
      required this.text,
      required this.borderColor,
      required this.backgroundColor,
      this.width,
      Key? key})
      : super(key: key);
  final Function onPressed;
  final String text;
  final Color borderColor;
  final Color backgroundColor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
            color: Palette.backgroundDark,
            border: Border.all(color: Palette.backgroundDark),
            borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: backgroundColor.withAlpha(50),
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

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

class AnimatedBlur extends ConsumerStatefulWidget {
  const AnimatedBlur({required this.duration, required this.delay, Key? key})
      : super(key: key);
  final Duration duration;
  final Duration delay;

  @override
  _AnimatedBlurState createState() => _AnimatedBlurState();
}

class _AnimatedBlurState extends ConsumerState<AnimatedBlur>
    with SingleTickerProviderStateMixin {
  double sigma = 3;
  late CurvedAnimationController<double> animationController;

  @override
  void initState() {
    super.initState();
    animationController = CurvedAnimationController(
        vsync: this, duration: widget.duration, curve: Curves.decelerate);
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
        animation: animationController,
        builder: (context, child) {
          int alpha = animationController.value!.round() * 220;
          return ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black.withAlpha(alpha),
            ),
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

class _AnimatedEntryState extends State<AnimatedEntry> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(widget.delay, () {
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
          duration: widget.duration, opacity: opacity, child: widget.child),
    );
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
