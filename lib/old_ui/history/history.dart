import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/old_ui/history/menuworkoutrecordcard.dart';

import 'package:lift_tracker/old_ui/session.dart';
import 'package:lift_tracker/old_ui/history/workoutrecordcard.dart';
import 'package:lift_tracker/old_ui/widgets.dart';

import '../../data/classes/workoutrecord.dart';

class History extends ConsumerStatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<History> {
  List<WorkoutRecord> workoutRecords = [];

  @override
  void initState() {
    super.initState();
    readMoreAndUpdateUI();
  }

  @override
  Widget build(BuildContext context) {
    workoutRecords = ref.watch(Helper.instance.workoutRecordsProvider);
    return SafeArea(
      child: Column(
        children: [
          workoutRecords.isNotEmpty
              ? Expanded(
                  child: Body(
                  records: workoutRecords,
                  readMoreCallback: readMoreAndUpdateUI,
                ))
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                        child: Text(
                      UIUtilities.loadTranslation(context, 'historyWelcome'),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    )),
                  ),
                )
        ],
      ),
    );
  }

  void readMoreAndUpdateUI() {
    CustomDatabase.instance.readWorkoutRecords().then((workoutRecords) {
      ref
          .read(Helper.instance.workoutRecordsProvider.notifier)
          .addWorkoutRecords(workoutRecords);
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'history: ' + error.toString());
    });
  }
}

class Body extends ConsumerStatefulWidget {
  const Body({Key? key, required this.records, required this.readMoreCallback})
      : super(key: key);
  final List<WorkoutRecord> records;
  final Function readMoreCallback;

  @override
  ConsumerState<Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<Body> {
  List<WorkoutRecord> records = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    records = widget.records;
  }

  @override
  void didUpdateWidget(covariant Body oldWidget) {
    super.didUpdateWidget(oldWidget);
    records = widget.records;
  }

  @override
  Widget build(BuildContext context) {
    int length = records.length;
    return Column(
      children: [
        SearchBar(
          hint: UIUtilities.loadTranslation(context, 'filter'),
          textController: searchController,
          onTextChange: (change) {
            List<WorkoutRecord> temp = [];
            if (change.isEmpty) {
              records = widget.records;
              setState(() {});
              return;
            }
            for (WorkoutRecord data in widget.records) {
              if (data.workoutName
                  .toLowerCase()
                  .contains(change.toLowerCase())) {
                temp.add(data);
              }
            }
            records = temp;
            setState(() {});
          },
        ),
        Expanded(
          child: ListView.builder(
              itemBuilder: (context, i) {
                if ((i + 1).remainder(CustomDatabase.instance.searchLimit) ==
                        0 &&
                    (i + 1) ~/ CustomDatabase.instance.searchLimit >
                        (CustomDatabase.instance.workoutRecordsCount - 1)) {
                  widget.readMoreCallback();
                }
                WorkoutRecordCard workoutRecordCard =
                    WorkoutRecordCard(records[i], () {});
                GlobalKey key = GlobalKey();
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: WorkoutRecordCard(records[i], () {
                    MaterialPageRoute route =
                        MaterialPageRoute(builder: (context) {
                      return Session(records[i]);
                    });
                    Navigator.push(context, route);
                  }, onLongPress: () async {
                    await Navigator.push(
                        context, blurredMenuBuilder(workoutRecordCard, key, i));
                  }),
                  key: key,
                );
              },
              itemCount: length),
        ),
      ],
    );
  }

  PageRouteBuilder blurredMenuBuilder(
      WorkoutRecordCard workoutRecordCard, GlobalKey key, int tag) {
    return PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        opaque: false,
        pageBuilder: (context, a1, a2) {
          return MenuWorkoutRecordCard(
              positionedAnimationDuration: const Duration(milliseconds: 150),
              workoutCardKey: key,
              workoutRecordCard: workoutRecordCard,
              heroTag: tag,
              editOnPressed: () {},
              deleteOnPressed: () async {
                if (await CustomDatabase.instance
                    .removeWorkoutRecord(workoutRecordCard.workoutRecord.id)) {
                  ref
                      .read(Helper.instance.workoutRecordsProvider.notifier)
                      .removeWorkoutRecord(workoutRecordCard.workoutRecord.id);
                }
                await Navigator.maybePop(context);
              },
              cancelOnPressed: () {
                Navigator.maybePop(context);
              });
        });
  }
}
