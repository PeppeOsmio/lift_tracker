import 'package:flutter/material.dart';
import 'package:lift_tracker/data/classes/exercisedata.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/gym_icons_icons.dart';
import 'package:lift_tracker/ui/widgets.dart';
import 'colors.dart';

class Exercises extends StatefulWidget {
  const Exercises({Key? key}) : super(key: key);

  @override
  _ExercisesState createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SearchBar(
              hint: Helper.loadTranslation(context, 'filter'),
              textController: TextEditingController()),
          Expanded(
              child: FutureBuilder(
                  future: Helper.getExerciseData(),
                  builder: (context, ss) {
                    if (ss.hasData) {
                      List<ExerciseData> exerciseData =
                          ss.data! as List<ExerciseData>;
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ListView.separated(
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: 16,
                              );
                            },
                            itemCount: exerciseData.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      bottom: index == exerciseData.length - 1
                                          ? 16
                                          : 0),
                                  child: ExerciseCard(
                                      exerciseData: exerciseData[index]),
                                ),
                              );
                            }),
                      );
                    }
                    if (ss.hasError) {
                      return Expanded(
                          child: Center(
                        child: Text('Error'),
                      ));
                    }
                    return SizedBox();
                  })),
        ],
      ),
    );
  }
}

class ExerciseCard extends StatefulWidget {
  const ExerciseCard({required this.exerciseData, Key? key}) : super(key: key);
  final ExerciseData exerciseData;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (widget.exerciseData.type) {
      case 'dumbbell':
        icon = GymIcons.dumbbell;
        break;
      case 'barebell':
        icon = GymIcons.barebell;
        break;
      case 'machine':
        icon = GymIcons.machine;
        break;
      case 'cardio':
        icon = GymIcons.cardio;
        break;
      case 'free':
        icon = GymIcons.cardio;
        break;
      default:
        icon = GymIcons.barebell;
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Palette.elementsDark, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          /*Expanded(
            flex: 1,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                'assets/images/chest_triceps_antdelts${widget.number}.png',
              ),
            ),
          ),*/
          CircleAvatar(
              radius: 26,
              foregroundColor: Palette.elementsDark,
              backgroundColor: Colors.blueGrey,
              child: Icon(
                icon,
                size: 26,
              )),
          Expanded(
            flex: 100,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      Helper.loadTranslation(context, widget.exerciseData.name),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildMuscleBadge(
                                Colors.red,
                                Helper.loadTranslation(
                                    context, widget.exerciseData.firstMuscle)),
                            const SizedBox(
                              width: 8,
                            ),
                            buildMuscleBadge(
                                Colors.blue,
                                Helper.loadTranslation(
                                    context, widget.exerciseData.secondMuscle)),
                            const SizedBox(
                              width: 8,
                            ),
                            buildMuscleBadge(
                                Colors.green,
                                Helper.loadTranslation(
                                    context, widget.exerciseData.thirdMuscle))
                          ]),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildMuscleBadge(Color color, String name) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.5),
          border: Border.all(color: color.withAlpha(0)),
          color: color.withAlpha(0)),
      child: Text(
        name,
        style:
            TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }
}
