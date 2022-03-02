import 'package:fluttericon/font_awesome5_icons.dart';

import 'package:flutter/material.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/ui/history/menuworkoutrecordcard.dart';

import 'package:lift_tracker/ui/session.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/history/workoutrecordcard.dart';
import 'package:lift_tracker/ui/widgets.dart';

import '../../data/workoutrecord.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late Future<List<WorkoutRecord>> workoutRecords;

  @override
  void initState() {
    super.initState();
    workoutRecords = CustomDatabase.instance.readWorkoutRecords();
    workoutRecords.then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.search_outlined,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(border: InputBorder.none),
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  )),
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: workoutRecords,
            builder: (context, ss) {
              if (ss.hasData) {
                List<WorkoutRecord> records = ss.data! as List<WorkoutRecord>;
                int length = records.length;
                return Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, i) {
                        WorkoutRecordCard workoutRecordCard =
                            WorkoutRecordCard(records[length - 1 - i], () {});
                        GlobalKey key = GlobalKey();
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: WorkoutRecordCard(records[length - 1 - i], () {
                            MaterialPageRoute route =
                                MaterialPageRoute(builder: (context) {
                              return Session(records[length - 1 - i]);
                            });
                            Navigator.push(context, route);
                          }, onLongPress: () {
                            Navigator.push(
                                    context,
                                    blurredMenuBuilder(
                                        workoutRecordCard, key, i))
                                .then((value) {
                              setState(() {});
                            });
                          }),
                          key: key,
                        );
                      },
                      separatorBuilder: (context, i) {
                        return const SizedBox();
                      },
                      itemCount: length),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  PageRouteBuilder blurredMenuBuilder(
      WorkoutRecordCard workoutRecordCard, GlobalKey key, int tag) {
    return PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        opaque: false,
        pageBuilder: (context, a1, a2) {
          return MenuWorkoutRecordCard(
              positionedAnimationDuration: const Duration(milliseconds: 200),
              workoutCardKey: key,
              workoutRecordCard: workoutRecordCard,
              heroTag: tag,
              deleteOnPressed: () async {
                await CustomDatabase.instance
                    .removeWorkoutRecord(workoutRecordCard.workoutRecord.id);
                workoutRecords = CustomDatabase.instance.readWorkoutRecords();
                Navigator.maybePop(context);
              },
              cancelOnPressed: () {
                Navigator.maybePop(context);
              });
        });
  }
}
