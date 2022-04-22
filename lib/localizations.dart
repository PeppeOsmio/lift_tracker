import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Localization {
  Localization(this.locale);

  final Locale locale;

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization)!;
  }

  // The default values to be loaded when the selected file
  // misses a key.
  late Map<String, String> _defaultSentences;

  // The local values corresponding to the device's locale.
  late Map<String, String> _localSentences;

  Future<bool> load() async {
    // Loading all the global sentences in the "en.json" file
    String data = await rootBundle.loadString('assets/lang/en.json');
    Map<String, dynamic> _result = json.decode(data);

    _defaultSentences = {};
    _result.forEach((String key, dynamic value) {
      _defaultSentences[key] = value.toString();
    });

    // Loading all the local sentences from the calculated file
    data =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    _result = json.decode(data);

    _localSentences = {};
    _result.forEach((String key, dynamic value) {
      _localSentences[key] = value.toString();
    });

    return true;
  }

  String getString(String key) {
    // Check first for the _localSentences, then for the _defaultSentences.
    // If they both miss the requested key, then return "".
    // Might consider throwing an error.
    return _localSentences[key] ?? _defaultSentences[key] ?? "";
  }
}

class DemoLocalizationsDelegate extends LocalizationsDelegate<Localization> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'it'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) async {
    Localization localizations = Localization(locale);
    await localizations.load();

    print("Load ${locale.languageCode}");

    return localizations;
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}
