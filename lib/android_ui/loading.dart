import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/android_ui/app/app.dart';
import 'package:lift_tracker/localizations.dart';

class Loading extends ConsumerStatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  ConsumerState<Loading> createState() => _LoadingState();
}

class _LoadingState extends ConsumerState<Loading> {
  ColorScheme Function()? getColorScheme;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: ((lightDynamic, darkDynamic) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        lightColorScheme = lightDynamic.harmonized().copyWith();
        darkColorScheme = darkDynamic.harmonized().copyWith();
      } else {
        lightColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.orange, brightness: Brightness.light);
        darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.orange, brightness: Brightness.dark);
      }
      bool useMaterial3 = lightDynamic != null && darkDynamic != null;
      useMaterial3 = true;
      lightColorScheme = lightColorScheme;
      ColorScheme colorScheme =
          (MediaQuery.of(context).platformBrightness == Brightness.dark
              ? darkColorScheme
              : lightColorScheme);

      ThemeData theme = ThemeData(
        useMaterial3: useMaterial3,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.background,
        dialogBackgroundColor: colorScheme.surface,
        cardColor: colorScheme.surface,
        popupMenuTheme: Theme.of(context)
            .popupMenuTheme
            .copyWith(color: colorScheme.surfaceVariant),
      );

      return MaterialApp(
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
      );
    }));
  }
}
