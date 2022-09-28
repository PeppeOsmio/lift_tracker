import 'dart:developer';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/app/app.dart';
import 'package:lift_tracker/android_ui/settings/settings.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/localizations.dart';

class Loading extends ConsumerStatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  ConsumerState<Loading> createState() => _LoadingState();
}

class _LoadingState extends ConsumerState<Loading> {
  bool isThemeReady = false;
  bool isFirstRun = true;
  ThemeData? theme;
  bool didSettingsChange = false;
  bool mustRebuildForPalette = false;
  bool didAlreadyUsePalette = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: ((lightDynamic, darkDynamic) {
      Future.delayed(Duration.zero, () async {
        if (Settings.instance.onSettingsUpdateListener == null && isFirstRun) {
          Settings.instance.onSettingsUpdateListener = (oldSettings) {
            setState(() {
              didSettingsChange = true;
            });
          };
        }

        await Settings.instance.getSettings();
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;
        if (lightDynamic != null &&
            darkDynamic != null &&
            Settings.instance.useSystemPalette) {
          mustRebuildForPalette = true;
          lightColorScheme = lightDynamic.harmonized().copyWith();
          darkColorScheme = darkDynamic.harmonized().copyWith();
        } else if (Settings.instance.sharedPreferences!.getInt('mainColor') ==
            null) {
          lightColorScheme = ColorScheme.fromSeed(
              seedColor: Colors.orange, brightness: Brightness.light);
          darkColorScheme = ColorScheme.fromSeed(
              seedColor: Colors.orange, brightness: Brightness.dark);
        } else {
          lightColorScheme = ColorScheme.fromSeed(
              seedColor: Settings.instance.mainColor,
              brightness: Brightness.light);
          darkColorScheme = ColorScheme.fromSeed(
              seedColor: Settings.instance.mainColor,
              brightness: Brightness.dark);
        }
        lightColorScheme = lightColorScheme;
        ColorScheme colorScheme =
            (MediaQuery.of(context).platformBrightness == Brightness.dark
                ? darkColorScheme
                : lightColorScheme);

        theme = ThemeData(
          useMaterial3: Settings.instance.useMaterial3,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: colorScheme.background,
          dialogBackgroundColor: colorScheme.surface,
          cardColor: colorScheme.surface,
          popupMenuTheme: Theme.of(context)
              .popupMenuTheme
              .copyWith(color: colorScheme.surfaceVariant),
        );
        if (isFirstRun ||
            didSettingsChange ||
            (mustRebuildForPalette && !didAlreadyUsePalette)) {
          setState(() {
            if (mustRebuildForPalette) {
              mustRebuildForPalette = false;
              didAlreadyUsePalette = true;
            }
            isThemeReady = true;
            isFirstRun = false;
            didSettingsChange = false;
          });
        }
      });

      return !isThemeReady
          ? SizedBox()
          : AnimatedTheme(
              data: theme!,
              curve: Curves.decelerate,
              duration: Duration(milliseconds: 300),
              child: MaterialApp(
                supportedLocales: const [
                  Locale('en', ''),
                  Locale('it', ''),
                ],
                localizationsDelegates: const [
                  DemoLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate
                ],
                localeResolutionCallback:
                    (Locale? locale, Iterable<Locale> supportedLocales) {
                  if (locale == null) return supportedLocales.first;

                  for (Locale supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale.languageCode ||
                        supportedLocale.countryCode == locale.countryCode) {
                      return supportedLocale;
                    }
                  }
                  return supportedLocales.first;
                },
                theme: theme,
                home: App(useMaterial3: true),
                debugShowCheckedModeBanner: false,
              ),
            );
    }));
  }
}
