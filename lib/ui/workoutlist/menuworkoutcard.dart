import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lift_tracker/data/classes/workouthistory.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/ui/workoutlist/workoutcard.dart';
import 'package:lift_tracker/ui/workouthistory/workouthistorypage.dart';
import '../../data/helper.dart';
import '../workouts/editworkout.dart';
import '../newsession/newsession.dart';
import '../widgets.dart';

class MenuWorkoutCard extends StatefulWidget {
  const MenuWorkoutCard(
      {required this.positionedAnimationDuration,
      required this.workoutCardKey,
      required this.workoutCard,
      required this.deleteOnPressed,
      required this.cancelOnPressed,
      required this.hasHistory,
      Key? key})
      : super(key: key);
  final WorkoutCard workoutCard;
  final void Function() deleteOnPressed;
  final void Function() cancelOnPressed;
  final Duration positionedAnimationDuration;
  final GlobalKey workoutCardKey;
  final bool hasHistory;

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
      if ((originalHeight +
              (widget.workoutCard.workout.exercises.length - 5) * 30) <
          (screenHeight * 0.9)) {
        finalCardY = (screenHeight -
                originalHeight -
                (widget.workoutCard.workout.exercises.length - 5) * 30) /
            2;
      } else {
        finalCardY = 50;
        setState(() {});
      }
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
      screenHeight = MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom;
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
          body: GestureDetector(
              onTap: () {
                Navigator.maybePop(context);
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: (originalHeight +
                              (widget.workoutCard.workout.exercises.length -
                                      5) *
                                  30) <
                          (screenHeight)
                      ? NeverScrollableScrollPhysics()
                      : null,
                  child: Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.maybePop(context);
                          },
                          child: DimmingBackground(
                            blurred: false,
                            duration: widget.positionedAnimationDuration,
                            maxAlpha: 130,
                          )),
                      AnimatedPositioned(
                        curve: Curves.decelerate,
                        duration: widget.positionedAnimationDuration,
                        width: MediaQuery.of(context).size.width,
                        top: cardY,
                        child: AnimatedOpacity(
                          curve: Curves.decelerate,
                          duration: widget.positionedAnimationDuration,
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
                        child: AnimatedOpacity(
                          opacity: opacity,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.decelerate,
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
                                  text:
                                      Helper.loadTranslation(context, 'delete'),
                                  borderColor: Colors.red,
                                  backgroundColor: Colors.red.withAlpha(25),
                                ),
                              ),
                              widget.hasHistory
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8, right: 8),
                                      child: CardMenuButton(
                                          onPressed: () async {
                                            var history = await CustomDatabase
                                                .instance
                                                .getWorkoutHistory(
                                                    widget.workoutCard.workout);
                                            Navigator.pushReplacement(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return WorkoutHistoryPage(
                                                  workoutHistory: history);
                                            }));
                                          },
                                          text: Helper.loadTranslation(
                                              context, 'history'),
                                          borderColor: Colors.lightBlue,
                                          backgroundColor:
                                              Colors.lightBlue.withAlpha(25)),
                                    )
                                  : SizedBox(),
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
                                    text:
                                        Helper.loadTranslation(context, 'edit'),
                                    borderColor: Colors.amber,
                                    backgroundColor:
                                        Colors.amber.withAlpha(25)),
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
                                    text: Helper.loadTranslation(
                                        context, 'start'),
                                    borderColor: Colors.green,
                                    backgroundColor:
                                        Colors.green.withAlpha(25)),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ))),
    );
  }
}
