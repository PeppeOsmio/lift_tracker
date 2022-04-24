import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:lift_tracker/data/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/ui/history/menuworkoutrecordcard.dart';

import 'package:lift_tracker/ui/session.dart';
import 'package:lift_tracker/ui/history/workoutrecordcard.dart';
import 'package:lift_tracker/ui/widgets.dart';

import '../../data/classes/workoutrecord.dart';

class History extends ConsumerStatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<History> {
  late Future<List<WorkoutRecord>> workoutRecords;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    workoutRecords = ref.watch(Helper.workoutRecordsProvider);
    return SafeArea(
      child: Column(
        children: [
          FutureBuilder(
            future: workoutRecords,
            builder: (context, ss) {
              if (ss.hasData) {
                List<WorkoutRecord> records = ss.data! as List<WorkoutRecord>;
                if (records.isNotEmpty) {
                  return Expanded(child: Body(records: records));
                } else {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Text(
                        Helper.loadTranslation(context, 'historyWelcome'),
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                      )),
                    ),
                  );
                }
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

class Body extends ConsumerStatefulWidget {
  const Body({Key? key, required this.records}) : super(key: key);
  final List<WorkoutRecord> records;

  @override
  ConsumerState<Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<Body> {
  List<WorkoutRecord> records = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    records = widget.records;
  }

  @override
  Widget build(BuildContext context) {
    int length = records.length;
    return Column(
      children: [
        SearchBar(
          hint: Helper.loadTranslation(context, 'filter'),
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
              deleteOnPressed: () async {
                await CustomDatabase.instance
                    .removeWorkoutRecord(workoutRecordCard.workoutRecord.id);
                ref
                    .read(Helper.workoutRecordsProvider.notifier)
                    .refreshWorkoutRecords();
                await Navigator.maybePop(context);
              },
              cancelOnPressed: () {
                Navigator.maybePop(context);
              });
        });
  }
}
