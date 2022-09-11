import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/old_ui/styles.dart';
import 'package:lift_tracker/old_ui/widgets.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Palette.backgroundDark,
        body: Column(children: [
          CustomAppBar(
              middleText: UIUtilities.loadTranslation(context, 'profile'),
              onBack: () => Navigator.pop(context),
              onSubmit: () {},
              backButton: true,
              submitButton: false)
        ]),
      ),
    );
  }
}
