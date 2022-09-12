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
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  bool isListReady = false;

  @override
  void initState() {
    super.initState();
    log('Building History...');
    CustomDatabase.instance.readWorkoutRecords(readAll: true).then((value) {
      isListReady = true;
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
          workoutRecord: workoutRecords[index],
          onCardTap: () {
            if (openIndex == index) {
              setState(() {
                openIndex = null;
              });
            }
          },
          onCardLongPress: () {
            if (openIndex == index) {
              setState(() {
                openIndex = null;
              });
            } else {
              setState(() {
                openIndex = index;
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

  @override
  Widget build(BuildContext context) {
    workoutRecords = ref.watch(Helper.instance.workoutRecordsProvider);
    List<Widget> bodyItems = body();
    return Scaffold(
      backgroundColor: UIUtilities.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: isAppBarSelected
            ? UIUtilities.getSelectedAppBarColor(context)
            : UIUtilities.getAppBarColor(context),
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
                              if (openIndex != null) {}
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
      body: isListReady
          ? AnimatedList(
              key: animatedListKey,
              initialItemCount: bodyItems.length,
              itemBuilder: ((context, index, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                      sizeFactor: animation, child: bodyItems[index]),
                );
              }),
            )
          : Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
