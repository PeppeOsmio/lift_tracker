import 'dart:ui';
import 'package:curved_animation_controller/curved_animation_controller.dart';
import 'package:flutter/material.dart';
import 'package:lift_tracker/editworkout.dart';
import 'package:lift_tracker/newsession.dart';
import '../data/constants.dart';
import '../history.dart';
import 'workoutcard.dart';
import 'colors.dart';

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
              padding: const EdgeInsets.only(left: 24),
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
                          //onTap: createWorkoutSession,
                          child: const Icon(
                            Icons.check_outlined,
                            color: Colors.green,
                          ))),
                )
              : SizedBox()
        ],
      ),
    );
  }
}

class BlurredProfileMenu extends StatefulWidget {
  const BlurredProfileMenu({Key? key}) : super(key: key);

  @override
  BlurredProfileMenuState createState() => BlurredProfileMenuState();
}

class BlurredProfileMenuState extends State<BlurredProfileMenu> {
  GlobalKey containerKey = GlobalKey();
  double menuOpacity = 0;

  Offset getOffset(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    double dy = renderBox.localToGlobal(Offset.zero).dy;
    double dx = renderBox.localToGlobal(Offset.zero).dx;
    return Offset(dx, dy);
  }

  Size getSize(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size;
  }

  Widget button(bool isOpen) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: Container(
          height: 6,
          width: 60,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Palette.elementsDark,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: FittedBox(
              child: Icon(
            isOpen ? Icons.more_horiz : Icons.person,
            color: Colors.white,
          ))),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(key: containerKey, child: button(false)),
      onTap: () {
        Constants.unfocusTextFields(context);
        PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, _, __) {
              Offset offset = getOffset(containerKey);
              Size size = getSize(containerKey);
              return Material(
                type: MaterialType.transparency,
                child: WillPopScope(
                    onWillPop: () async {
                      return true;
                    },
                    child: Stack(children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.maybePop(context);
                        },
                        child: const AnimatedBlur(
                            duration: Duration(milliseconds: 200),
                            delay: Duration.zero),
                      ),
                      Positioned(
                          top: offset.dy,
                          left: offset.dx,
                          child:
                              //with align and sizedbox we can force the widget to
                              //have a specific size
                              Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                                width: size.width,
                                height: size.height,
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.maybePop(context);
                                    },
                                    child: button(true))),
                          )),
                      Positioned(
                          top: offset.dy + size.height + 16,
                          right: 16,
                          child: AnimatedMenu())
                    ])),
              );
            });
        Navigator.push(context, pageRouteBuilder);
      },
    );
  }
}

class AnimatedMenu extends StatefulWidget {
  const AnimatedMenu({Key? key}) : super(key: key);

  @override
  _AnimatedMenuState createState() => _AnimatedMenuState();
}

class _AnimatedMenuState extends State<AnimatedMenu> {
  double menuOpacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        menuOpacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(color: Colors.white, fontSize: 18);
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          menuOpacity = 0;
        });
        return true;
      },
      child: AnimatedOpacity(
        curve: Curves.decelerate,
        duration: const Duration(milliseconds: 200),
        opacity: menuOpacity,
        child: Container(
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.maybePop(context);
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildMenuElement("Me", Icons.person, style),
                    SizedBox(
                      height: 16,
                    ),
                    buildMenuElement("Settings", Icons.settings, style),
                    SizedBox(
                      height: 16,
                    ),
                    buildMenuElement("Help", Icons.help, style)
                  ]),
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Palette.elementsDark.withAlpha(90)),
        ),
      ),
    );
  }

  Widget buildMenuElement(String text, IconData icon, TextStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: style,
        ),
        Spacer(),
        Icon(
          icon,
          color: Colors.white,
        )
      ],
    );
  }
}

class MenuWorkoutRecordCard extends StatefulWidget {
  const MenuWorkoutRecordCard(
      {required this.positionedAnimationDuration,
      required this.workoutCardKey,
      required this.workoutRecordCard,
      required this.heroTag,
      required this.deleteOnPressed,
      required this.cancelOnPressed,
      Key? key})
      : super(key: key);
  final WorkoutRecordCard workoutRecordCard;
  final int heroTag;
  final void Function() deleteOnPressed;
  final void Function() cancelOnPressed;
  final Duration positionedAnimationDuration;
  final GlobalKey workoutCardKey;

  @override
  _MenuWorkoutRecordCardState createState() => _MenuWorkoutRecordCardState();
}

class _MenuWorkoutRecordCardState extends State<MenuWorkoutRecordCard> {
  double originalHeight = 0;
  double startingY = 0;
  double screenWidth = 0;
  double screenHeight = 0;
  double finalCardY = 0;
  double cardY = 0;
  bool firstTimeBuilding = true;
  double opacity = 1;

  @override
  void initState() {
    super.initState();
    originalHeight = getCardRenderBox().size.height;
    Future.delayed(Duration.zero, () {
      finalCardY = (screenHeight - originalHeight) / 2;
      setState(() {
        cardY = finalCardY;
      });
    });
  }

  RenderBox getCardRenderBox() {
    return widget.workoutCardKey.currentContext!.findRenderObject()
        as RenderBox;
  }

  @override
  Widget build(BuildContext context) {
    if (firstTimeBuilding) {
      firstTimeBuilding = false;
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      startingY = getCardRenderBox().localToGlobal(Offset.zero).dy + 16;
      cardY = startingY;
    }
    return WillPopScope(
      onWillPop: () async {
        //move the card to the original position
        //after the card is in the original position fade it away
        setState(() {
          opacity = 0;
        });
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.maybePop(context);
                  },
                  child: const AnimatedBlur(
                    duration: Duration(milliseconds: 200),
                    delay: Duration(seconds: 0),
                  ),
                ),
                AnimatedPositioned(
                  curve: Curves.decelerate,
                  duration: const Duration(milliseconds: 200),
                  width: MediaQuery.of(context).size.width,
                  top: cardY,
                  child: AnimatedOpacity(
                    curve: Curves.decelerate,
                    duration: const Duration(milliseconds: 200),
                    opacity: opacity,
                    child: Material(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: widget.workoutRecordCard,
                        ),
                        type: MaterialType.transparency),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.decelerate,
                  right: 16,
                  bottom: MediaQuery.of(context).size.height - cardY,
                  child: AnimatedEntry(
                    duration: const Duration(milliseconds: 50),
                    delay: widget.workoutRecordCard.expandDuration * 0.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CardMenuButton(
                              onPressed: widget.deleteOnPressed,
                              text: "Delete",
                              borderColor: Colors.red,
                              backgroundColor: Colors.red.withAlpha(25),
                              width: 70),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
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
            color: backgroundColor,
            border: Border.all(color: Palette.backgroundDark),
            borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: backgroundColor,
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

class MenuWorkoutCard extends StatefulWidget {
  const MenuWorkoutCard(
      {required this.positionedAnimationDuration,
      required this.workoutCardKey,
      required this.workoutCard,
      required this.heroTag,
      required this.deleteOnPressed,
      required this.cancelOnPressed,
      Key? key})
      : super(key: key);
  final WorkoutCard workoutCard;
  final int heroTag;
  final void Function() deleteOnPressed;
  final void Function() cancelOnPressed;
  final Duration positionedAnimationDuration;
  final GlobalKey workoutCardKey;

  @override
  _MenuWorkoutCardState createState() => _MenuWorkoutCardState();
}

class _MenuWorkoutCardState extends State<MenuWorkoutCard> {
  double originalHeight = 0;
  double startingY = 0;
  double screenWidth = 0;
  double screenHeight = 0;
  double finalCardY = 0;
  double cardY = 0;
  bool firstTimeBuilding = true;
  double opacity = 1;

  @override
  void initState() {
    super.initState();
    originalHeight = getCardRenderBox().size.height;
    Future.delayed(Duration.zero, () {
      finalCardY = (screenHeight -
              originalHeight -
              (widget.workoutCard.workout.excercises.length - 5) * 30) /
          2;
      setState(() {
        cardY = finalCardY;
      });
    });
  }

  RenderBox getCardRenderBox() {
    return widget.workoutCardKey.currentContext!.findRenderObject()
        as RenderBox;
  }

  @override
  Widget build(BuildContext context) {
    if (firstTimeBuilding) {
      firstTimeBuilding = false;
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      startingY = getCardRenderBox().localToGlobal(Offset.zero).dy;
      cardY = startingY;
    }
    return WillPopScope(
      onWillPop: () async {
        //move the card to the original position
        //after the card is in the original position fade it away
        setState(() {
          opacity = 0;
        });
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
                onTap: () {
                  Navigator.maybePop(context);
                },
                child: Stack(
                  children: [
                    const AnimatedBlur(
                      duration: Duration(milliseconds: 200),
                      delay: Duration(seconds: 0),
                    ),
                    AnimatedPositioned(
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 200),
                      width: MediaQuery.of(context).size.width,
                      top: cardY,
                      child: AnimatedOpacity(
                        curve: Curves.decelerate,
                        duration: const Duration(milliseconds: 200),
                        opacity: opacity,
                        child: Material(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: widget.workoutCard,
                            ),
                            type: MaterialType.transparency),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.decelerate,
                      right: 16,
                      bottom: MediaQuery.of(context).size.height - cardY,
                      child: AnimatedEntry(
                        duration: const Duration(milliseconds: 50),
                        delay: widget.workoutCard.expandDuration * 0.5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8, right: 8),
                              child: CardMenuButton(
                                onPressed: () {
                                  widget.deleteOnPressed();
                                },
                                text: "Delete",
                                borderColor: Colors.red,
                                backgroundColor: Colors.red.withAlpha(25),
                                width: 70,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8, right: 8),
                              child: CardMenuButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return EditWorkout(
                                          widget.workoutCard.workout);
                                    }));
                                  },
                                  text: "Edit workout",
                                  borderColor: Colors.amber,
                                  backgroundColor: Colors.amber.withAlpha(25)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: CardMenuButton(
                                  onPressed: () {
                                    Route route =
                                        MaterialPageRoute(builder: (context) {
                                      return NewSession(
                                          widget.workoutCard.workout);
                                    });
                                    Navigator.pushReplacement(context, route);
                                  },
                                  text: "Start workout",
                                  borderColor: Colors.green,
                                  backgroundColor: Colors.green.withAlpha(25)),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
          )),
    );
  }
}

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
  late CurvedAnimationController animationController;

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
        child: const SizedBox(),
        animation: animationController,
        builder: (context, child) {
          var value = animationController.value;
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: value * 5, sigmaY: value * 5),
            child:
                Container(color: Colors.black.withAlpha((value * 100).round())),
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
    animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
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
      child:
          SizeTransition(sizeFactor: animationController, child: widget.child),
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
