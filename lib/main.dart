import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/localizations.dart';
import 'package:lift_tracker/ui/app/app.dart';

import 'ui/loading.dart';

void main() async {
  runApp(ProviderScope(
      child: MaterialApp(
    home: Loading(),
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
  )));
}
