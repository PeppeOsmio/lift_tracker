import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/app/app.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/android_ui/widgets/customanimatedicon.dart';
import 'package:lift_tracker/data/classes/workoutrecord.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/android_ui/history/workoutrecordcard.dart';
import 'package:lift_tracker/android_ui/session/session.dart';

class History extends ConsumerStatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  ConsumerState<History> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<History> {
  bool isAppBarSelected = false;
  String searchString = '';
  FocusNode searchFocusNode = FocusNode();
  List<bool> isOpenList = [];
  TextEditingController searchController = TextEditingController();
  List<WorkoutRecord> workoutRecords = [];
  bool isListReady = false;
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  bool toggleMenuAnimation = false;

  @override
  void initState() {
    super.initState();
    log('Building History...');
    Future.delayed(Duration.zero, () {
      // remove circular progress indicator
      animatedListKey.currentState!.removeItem(
          0,
          (context, animation) => SizedBox(
                height: 0,
              ),
          duration: Duration.zero);
      ref
          .read(Helper.instance.workoutRecordsProvider.notifier)
          .addListener((state) {
        if (state.length > workoutRecords.length) {
          isOpenList.add(false);
          for (int i = workoutRecords.length; i < state.length; i++) {
            animatedListKey.currentState!
                .insertItem(i, duration: Duration(milliseconds: 150));
          }
        }
      });
      readWorkoutRecords();
    });
  }

  void readWorkoutRecords() {
    CustomDatabase.instance.readWorkoutRecords().then((value) {
      ref
          .read(Helper.instance.workoutRecordsProvider.notifier)
          .addWorkoutRecords(value);
      for (int i = 0; i < value.length; i++) {
        isOpenList.add(false);
      }
    });
  }

  List<Widget> body() {
    return [
      ...workoutRecords.asMap().entries.map((mapEntry) {
        int index = mapEntry.key;
        return WorkoutRecordCard(
          key: ValueKey(workoutRecords[index].id),
          workoutRecord: workoutRecords[index],
          isSelected: isOpenList[index],
          onCardTap: () async {
            if (isAppBarSelected) {
              if (isOpenList[index]) {
                setState(() {
                  resetAppBarAndCards();
                });
              } else {
                setState(() {
                  isOpenList[index] = true;
                  isAppBarSelected = true;
                  toggleMenuAnimation = true;
                });
              }
              return;
            }
            MaterialPageRoute route = MaterialPageRoute(builder: (context) {
              return Session(workoutRecord: workoutRecords[index]);
            });
            await Navigator.push(context, route);
            setState(() {
              resetAppBarAndCards();
            });
          },
          onCardLongPress: () {
            if (isOpenList[index]) {
              setState(() {
                resetAppBarAndCards();
              });
            } else {
              setState(() {
                isOpenList[index] = true;
                isAppBarSelected = true;
                toggleMenuAnimation = true;
              });
            }
          },
        );
      }).toList()
    ];
  }

  void resetAppBarAndCards() {
    isAppBarSelected = false;
    isOpenList = isOpenList.map((e) => false).toList();
    searchString = '';
    searchController.text = '';
    toggleMenuAnimation = false;
  }

  Future removeWorkoutRecordCard(int index) async {
    WorkoutRecord workoutRecord = workoutRecords[index];
    bool success =
        await CustomDatabase.instance.removeWorkoutRecord(workoutRecord.id);
    if (!success) {
      return;
    }
    ref
            .read(Helper.instance.workoutsProvider.notifier)
            .getWorkoutdById(workoutRecord.workoutId)
            ?.hasHistory =
        await CustomDatabase.instance.hasHistory(workoutRecord.workoutId);

    try {
      animatedListKey.currentState!.removeItem(index, (context, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
              opacity: animation,
              child: WorkoutRecordCard(
                  key: ValueKey(workoutRecord.id),
                  workoutRecord: workoutRecord,
                  onCardTap: () async {},
                  onCardLongPress: () {})),
        );
      }, duration: Duration(milliseconds: 150));
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    workoutRecords = ref.watch(Helper.instance.workoutRecordsProvider);
    List<Widget> bodyItems = body();
    int openCards = 0;
    for (int i = 0; i < isOpenList.length; i++) {
      if (isOpenList[i]) {
        openCards++;
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isAppBarSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        leading: IconButton(
          onPressed: () {
            if (toggleMenuAnimation) {
              setState(() {
                resetAppBarAndCards();
              });
            } else {
              mainScaffoldKey.currentState!.openDrawer();
            }
          },
          icon: CustomAnimatedIcon(
              animatedIconData: AnimatedIcons.menu_arrow,
              start: toggleMenuAnimation),
        ),
        actions: [
          AnimatedSize(
            curve: Curves.decelerate,
            duration: Duration(milliseconds: 150),
            child: Row(
                children: isAppBarSelected
                    ? [
                        IconButton(
                            onPressed: () async {
                              List<int> ids = [];
                              for (int i = 0; i < isOpenList.length; i++) {
                                if (isOpenList[i]) {
                                  ids.add(workoutRecords[i].id);
                                  await removeWorkoutRecordCard(i);
                                }
                              }

                              for (int i = 0; i < ids.length; i++) {
                                await Future.delayed(
                                    Duration(milliseconds: 100));
                                ref
                                    .read(Helper.instance.workoutRecordsProvider
                                        .notifier)
                                    .removeWorkoutRecord(ids[i]);
                              }
                              resetAppBarAndCards();
                            },
                            icon: Icon(Icons.delete))
                      ]
                    : [
                        IconButton(
                            onPressed: () {}, icon: Icon(Icons.filter_list))
                      ]),
          )
        ],
        title: AnimatedSize(
          curve: Curves.decelerate,
          duration: Duration(milliseconds: 150),
          child: Text(isAppBarSelected
              ? UIUtilities.loadTranslation(context, 'nSelected')
                  .replaceFirst(RegExp('%s'), openCards.toString())
              : UIUtilities.loadTranslation(context, 'history')),
        ),
      ),
      body: GestureDetector(
          onTap: () {
            resetAppBarAndCards();
            setState(() {});
          },
          child: AnimatedList(
            key: animatedListKey,
            // show circular progress indicator if we did not yet read workout records
            initialItemCount:
                CustomDatabase.instance.didReadWorkoutRecords ? 0 : 1,
            itemBuilder: (context, index, animation) {
              if (!CustomDatabase.instance.didReadWorkoutRecords) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }
              if ((index + 1) == CustomDatabase.instance.workoutRecordsCount &&
                  !CustomDatabase.instance.didReadAllWorkoutRecords) {
                readWorkoutRecords();
              }
              return FadeTransition(
                  opacity: animation, child: bodyItems[index]);
            },
          )),
    );
  }
}
