import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_tracker/android_ui/widgets/dimmingbackground.dart';
import 'package:lift_tracker/localizations.dart';

class UIUtilities {
  static Color getSelectedAppBarColor(BuildContext context) {
    return Color.lerp(Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).appBarTheme.backgroundColor, 0)!;
  }

  static Color? getSelectedTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }

  static Color getScaffoldBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  static Color getAppBarTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondaryContainer;
  }

  static Color getSelectedWidgetColor(BuildContext context) {
    return Color.lerp(Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.surface, 0.9)!;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getRecordsBackgroundColor(BuildContext context) {
    return Color.lerp(Theme.of(context).colorScheme.secondary,
        Theme.of(context).colorScheme.surface, 0.85)!;
  }

  static Color getVolumeBackgroundColor(BuildContext context) {
    return Color.lerp(Theme.of(context).colorScheme.tertiary,
        Theme.of(context).colorScheme.surface, 0.85)!;
  }

  static InputDecoration getTextFieldDecoration(
      BuildContext context, String? label) {
    return InputDecoration(
        contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
        border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.onBackground)),
        floatingLabelBehavior:
            Theme.of(context).inputDecorationTheme.floatingLabelBehavior,
        label: Text(label ?? ''));
  }

  static void unfocusTextFields(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static String loadTranslation(BuildContext context, String key) {
    return Localization.of(context).getString(key);
  }

  static void showSnackBar(
      {required BuildContext context, required dynamic msg}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg.toString())));
  }

  static Future showDimmedBackgroundDialog(BuildContext context,
      {String? title,
      String? content,
      required String rightText,
      required String leftText,
      required Function rightOnPressed,
      required Function leftOnPressed,
      bool fullscreen = false,
      bool blurred = false,
      Function? onDispose}) async {
    UIUtilities.unfocusTextFields(context);
    if (fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    }
    await showDialog(
        useRootNavigator: false,
        barrierColor: Colors.transparent,
        context: context,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () async {
              if (onDispose != null) {
                onDispose();
              }
              return true;
            },
            child: Stack(children: [
              GestureDetector(
                  onTap: () {
                    Navigator.maybePop(context);
                  },
                  child: DimmingBackground(
                    blurred: blurred,
                    duration: Duration(milliseconds: 150),
                    maxAlpha: 138,
                  )),
              AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.background,
                title: title != null ? Text(title) : null,
                content: content != null ? Text(content) : null,
                actions: [
                  TextButton(
                      onPressed: () {
                        leftOnPressed();
                      },
                      child: Text(
                        leftText,
                        style: TextStyle(color: getPrimaryColor(context)),
                      )),
                  TextButton(
                      onPressed: () {
                        rightOnPressed();
                      },
                      child: Text(rightText,
                          style: TextStyle(color: getPrimaryColor(context)))),
                ],
              ),
            ]),
          );
        });
    if (fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    }
  }
}
