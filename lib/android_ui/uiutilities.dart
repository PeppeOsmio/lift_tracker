import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:lift_tracker/android_ui/widgets/dimmingbackground.dart';
import 'package:lift_tracker/localizations.dart';

class UIUtilities {
  static Color getAppBarColor(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      return Theme.of(context).colorScheme.background;
    }
    return Theme.of(context).colorScheme.secondaryContainer;
  }

  static Color getSelectedAppBarColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  static Color getSelectedTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }

  static Color getScaffoldBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  static Color getAppBarTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondaryContainer;
  }

  static Color getSelectedWidgetColor(BuildContext context) {
    return Color.lerp(getSelectedAppBarColor(context),
        Theme.of(context).colorScheme.surface, 0.45)!;
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
      bool blurred = true,
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
                title: title != null ? Text(title) : null,
                content: content != null ? Text(content) : null,
                actions: [
                  TextButton(
                      onPressed: () {
                        leftOnPressed();
                      },
                      child: Text(leftText)),
                  TextButton(
                      onPressed: () {
                        rightOnPressed();
                      },
                      child: Text(rightText)),
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
