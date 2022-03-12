import 'package:flutter/material.dart';
import 'package:lift_tracker/gym_icons_icons.dart';
import 'colors.dart';

class Exercises extends StatefulWidget {
  const Exercises({Key? key}) : super(key: key);

  @override
  _ExercisesState createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  @override
  Widget build(BuildContext context) {
    List<String> push = ['Chest', 'Triceps', 'Anterior delts'];
    List<String> pull = ['Lats', 'Middle traps', 'Biceps'];
    List<String> cardio = ['Cardio', '', ''];
    List<String> legs_push = ['Quads', 'Glutes', 'Calves'];
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
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Filter...',
                        border: InputBorder.none),
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  )),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                      number: 1,
                      name: 'Bench press (Barebell)',
                      icon: GymIcons.barebell,
                      muscles: push,
                    )),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ExerciseCard(
                      number: 1,
                      name: 'Bench press (Dumbbell)',
                      icon: GymIcons.dumbbell,
                      muscles: push),
                ),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                        number: 1,
                        name: 'Chest press',
                        icon: GymIcons.machine,
                        muscles: push)),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                        number: 1,
                        name: 'Lat machine',
                        icon: GymIcons.machine,
                        muscles: pull)),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                        number: 1,
                        name: 'Bent-over row (Barebell)',
                        icon: GymIcons.barebell,
                        muscles: pull)),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                        number: 1,
                        name: 'Bent-over row (Dumbbell)',
                        icon: GymIcons.dumbbell,
                        muscles: pull)),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                        number: 1,
                        name: 'Rope jump',
                        icon: GymIcons.cardio,
                        muscles: cardio)),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                        number: 1,
                        name: 'Inclined chest press',
                        icon: GymIcons.machine,
                        muscles: push)),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                        number: 1,
                        name: 'Squat',
                        icon: GymIcons.barebell,
                        muscles: legs_push)),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                        number: 1,
                        name: 'Leg extensions',
                        icon: GymIcons.machine,
                        muscles: ['Quads', '', ''])),
                Padding(
                    padding: EdgeInsets.all(16),
                    child: ExerciseCard(
                        number: 1,
                        name: 'Leg curls',
                        icon: GymIcons.machine,
                        muscles: ['Hamstrings', 'Glutes', ''])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseCard extends StatefulWidget {
  const ExerciseCard(
      {required this.number,
      required this.name,
      required this.icon,
      required this.muscles,
      Key? key})
      : super(key: key);
  final int number;
  final String name;
  final IconData icon;
  final List<String> muscles;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    print(widget.icon.codePoint);
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
                widget.icon,
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
                      widget.name,
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
                            buildMuscleBadge(Colors.red, widget.muscles[0]),
                            const SizedBox(
                              width: 8,
                            ),
                            buildMuscleBadge(Colors.blue, widget.muscles[1]),
                            const SizedBox(
                              width: 8,
                            ),
                            buildMuscleBadge(Colors.green, widget.muscles[2])
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
