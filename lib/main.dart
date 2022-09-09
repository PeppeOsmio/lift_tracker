import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/localizations.dart';

import 'android_ui/loading.dart';

void main() async {
  runApp(ProviderScope(
      child: MaterialApp(
    home: Loading(),
    debugShowCheckedModeBanner: false,
  )));
}
