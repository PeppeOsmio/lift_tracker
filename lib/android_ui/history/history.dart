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
  int? openIndex = null;
  TextEditingController searchController = TextEditingController();
  List<WorkoutRecord> workoutRecords = [];
  bool isListReady = false;
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();

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
    });
  }

  List<Widget> body() {
    return [
      ...workoutRecords.asMap().entries.map((mapEntry) {
        int index = mapEntry.key;
        return WorkoutRecordCard(
          key: ValueKey(workoutRecords[index].id),
          workoutRecord: workoutRecords[index],
          onCardTap: () async {
            if (openIndex == index) {
              setState(() {
                resetAppBarAndCards();
              });
            } else {
              MaterialPageRoute route = MaterialPageRoute(builder: (context) {
                return Session(workoutRecord: workoutRecords[index]);
              });
              await Navigator.push(context, route);
            }
          },
          onCardLongPress: () {
            if (openIndex == index) {
              setState(() {
                resetAppBarAndCards();
              });
            } else {
              setState(() {
                openIndex = index;
                isAppBarSelected = true;
              });
            }
          },
          textColor: openIndex == index
              ? UIUtilities.getSelectedTextColor(context)
              : null,
          color: openIndex == index
              ? UIUtilities.getSelectedWidgetColor(context)
              : null,
        );
      }).toList()
    ];
  }

  void resetAppBarAndCards() {
    isAppBarSelected = false;
    openIndex = null;
  }

  void removeWorkoutRecordCard(int index) async {
    WorkoutRecord workoutRecord = workoutRecords[index];
    bool success =
        await CustomDatabase.instance.removeWorkoutRecord(workoutRecord.id);
    if (!success) {
      return;
    }
    resetAppBarAndCards();
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
    ref
        .read(Helper.instance.workoutRecordsProvider.notifier)
        .removeWorkoutRecord(workoutRecord.id);
  }

  @override
  Widget build(BuildContext context) {
    workoutRecords = ref.watch(Helper.instance.workoutRecordsProvider);
    List<Widget> bodyItems = body();
    return Scaffold(
      backgroundColor: UIUtilities.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: isAppBarSelected
            ? UIUtilities.getSelectedAppBarColor(context)
            : null,
        leading: IconButton(
          onPressed: () {
            mainScaffoldKey.currentState!.openDrawer();
          },
          icon: CustomAnimatedIcon(
              animatedIconData: AnimatedIcons.menu_arrow, start: false),
        ),
        actions: [
          AnimatedSize(
            curve: Curves.decelerate,
            duration: Duration(milliseconds: 150),
            child: Row(
                children: isAppBarSelected
                    ? [
                        IconButton(
                            onPressed: () {
                              if (openIndex != null) {
                                removeWorkoutRecordCard(openIndex!);
                              }
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
          child: Text(isAppBarSelected && openIndex != null
              ? 'Delete session'
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
