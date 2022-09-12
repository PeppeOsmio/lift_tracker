import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lift_tracker/android_ui/app/app.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/helper.dart';

class CustomDrawer extends Drawer {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.secondary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lift Tracker',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 24),
                  ),
                  //Image.asset('assets/icon/icon.png')
                ],
              )),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(UIUtilities.loadTranslation(context, 'exit')),
            onTap: () {
              mainScaffoldKey.currentState!.closeDrawer();
              Navigator.maybePop(context);
            },
          )
        ],
      ),
    );
    ;
  }
}