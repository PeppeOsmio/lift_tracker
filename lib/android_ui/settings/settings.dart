import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lift_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static final instance = Settings._init();
  Settings._init();

  Function(SharedPreferences? oldSettings)? onSettingsUpdateListener;
  SharedPreferences? sharedPreferences;

  Future getSettings() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  bool get useMaterial3 {
    return sharedPreferences!.getBool('useMaterial3') ?? true;
  }

  Future setUseMaterial3(bool value) async {
    SharedPreferences oldSettings = sharedPreferences!;
    await sharedPreferences!.setBool('useMaterial3', value);
    onSettingsUpdateListener?.call(oldSettings);
    log('Updated settings');
  }

  bool get useSystemPalette {
    return sharedPreferences!.getBool('useSystemPalette') ?? true;
  }

  Future setUseSystemPalette(bool value) async {
    SharedPreferences oldSettings = sharedPreferences!;
    await sharedPreferences!.setBool('useSystemPalette', value);
    onSettingsUpdateListener?.call(oldSettings);
    log('Updated settings');
  }

  Color get mainColor {
    int? mainColor = sharedPreferences!.getInt('mainColor');
    if (mainColor == null) {
      return Colors.orange;
    }
    return Color(sharedPreferences!.getInt('mainColor')!);
  }

  Future setMainColor(Color value) async {
    SharedPreferences oldSettings = sharedPreferences!;
    await sharedPreferences!.setInt('mainColor', value.value);
    onSettingsUpdateListener?.call(oldSettings);
    log('Updated settings');
  }

  String? get backupPath {
    String? backupPath = sharedPreferences!.getString('backupPath');
    return backupPath;
  }

  Future setBackupPath(String value) async {
    SharedPreferences oldSettings = sharedPreferences!;
    await sharedPreferences!.setString('backupPath', value);
    onSettingsUpdateListener?.call(oldSettings);
    log('Updated settings');
  }
}
