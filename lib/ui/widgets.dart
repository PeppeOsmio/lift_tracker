import 'dart:ui';
import 'package:curved_animation_controller/curved_animation_controller.dart';
import 'package:flutter/material.dart';
import 'package:lift_tracker/editworkout.dart';
import 'package:lift_tracker/newsession.dart';
import '../history.dart';
import 'workoutcard.dart';
import 'colors.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu(this.buttonKey, {Key? key}) : super(key: key);
  final GlobalKey buttonKey;

  @override
  ProfileMenuState createState() => ProfileMenuState();
}

class ProfileMenuState extends State<ProfileMenu> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Stack(children: [
          const AnimatedBlur(
              duration: Duration(milliseconds: 200), delay: Duration.zero),
          GestureDetector(
            onTap: () {
              Navigator.maybePop(context);
            },
            child: Scaffold(
              appBar: AppBar(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  toolbarHeight: 79,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16, top: 16),
                      child: Container(
                          height: 6,
                          width: 60,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: Palette.elementsDark,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
                          child: const FittedBox(child: Icon(Icons.person))),
                    )
                  ]),
              backgroundColor: Colors.transparent,
            ),
          ),
        ]));
  }

  RenderBox getButtonRenderBox(GlobalKey key) {
    return key.currentContext!.findRenderObject() as RenderBox;
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
        setState(() {
          cardY = startingY;
        });
        //after the card is in the original position fade it away
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            opacity = 0;
          });
        });
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.black.withAlpha(100),
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
                    duration: const Duration(milliseconds: 400),
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
                          child: GestureDetector(
                            onTap: widget.deleteOnPressed,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(25),
                                  border:
                                      Border.all(color: Palette.backgroundDark),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                width: 70,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(25),
                                    border: Border.all(color: Colors.redAccent),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
        setState(() {
          cardY = startingY;
        });
        //after the card is in the original position fade it away
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            opacity = 0;
          });
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
                        duration: const Duration(milliseconds: 400),
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
                              child: GestureDetector(
                                onTap: widget.deleteOnPressed,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(25),
                                      border: Border.all(
                                          color: Palette.backgroundDark),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                    width: 70,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.red.withAlpha(25),
                                        border:
                                            Border.all(color: Colors.redAccent),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8, right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return EditWorkout(
                                        widget.workoutCard.workout);
                                  }));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.amber.withAlpha(25),
                                      border: Border.all(
                                          color: Palette.backgroundDark),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.amber.withAlpha(25),
                                        border: Border.all(
                                            color: Colors.amberAccent),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Text(
                                        "Edit workout",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    Route route =
                                        MaterialPageRoute(builder: (context) {
                                      return NewSession(
                                          widget.workoutCard.workout);
                                    });
                                    Navigator.pushReplacement(context, route);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Palette.backgroundDark,
                                        border: Border.all(
                                            color: Palette.backgroundDark),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Colors.green.withAlpha(25),
                                          border:
                                              Border.all(color: Colors.green),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Center(
                                        child: Text(
                                          "Start this workout",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
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
            filter: ImageFilter.blur(sigmaX: value * 10, sigmaY: value * 10),
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
