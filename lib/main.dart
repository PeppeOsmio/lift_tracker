import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lift_tracker/ui/app/app.dart';

void main() {
  runApp(ProviderScope(child: const MaterialApp(home: App())));
}
