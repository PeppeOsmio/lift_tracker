import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/ui/workoutlist/workoutcard.dart';

import '../../data/helper.dart';
import '../editworkout.dart';
import '../newsession.dart';
import '../widgets.dart';

class MenuWorkoutCard extends StatefulWidget {
  const MenuWorkoutCard(
      {required this.positionedAnimationDuration,
      required this.workoutCardKey,
      required this.workoutCard,
      required this.deleteOnPressed,
      required this.cancelOnPressed,
      Key? key})
      : super(key: key);
  final WorkoutCard workoutCard;
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
  double opacity = 0;

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
        opacity = 1;
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
          cardY = startingY;
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
                    GestureDetector(
                        onTap: () {
                          Navigator.maybePop(context);
                        },
                        child: DimmingBackground(
                            duration: const Duration(milliseconds: 150))),
                    AnimatedPositioned(
                      curve: Curves.decelerate,
                      duration: widget.positionedAnimationDuration,
                      width: MediaQuery.of(context).size.width,
                      top: cardY,
                      child: AnimatedOpacity(
                        curve: Curves.decelerate,
                        duration: const Duration(milliseconds: 150),
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
                                    Navigator.pushReplacement(context,
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
