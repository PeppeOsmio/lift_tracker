import 'package:flutter/material.dart';
import 'package:lift_tracker/ui/history/workoutrecordcard.dart';
import 'package:lift_tracker/ui/widgets.dart';

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
            child: Stack(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.maybePop(context);
                    },
                    child: const DimmingBackground(
                      blurred: false,
                      duration: const Duration(milliseconds: 150),
                      maxAlpha: 130,
                    )),
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
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: opacity,
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
