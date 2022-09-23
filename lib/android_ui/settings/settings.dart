import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static final instance = Settings._init();
  Settings._init();

  Function(SharedPreferences? oldSettings)? onSettingsUpdateListener;
  SharedPreferences? sharedPreferences;

  Future getSettings() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future setBool({required String key, required bool value}) async {
    SharedPreferences? oldSettings = sharedPreferences;
    await sharedPreferences!.setBool(key, value);
    onSettingsUpdateListener?.call(oldSettings);
  }

  Future setInt({required String key, required int value}) async {
    SharedPreferences? oldSettings = sharedPreferences;
    await sharedPreferences!.setInt(key, value);
    onSettingsUpdateListener?.call(oldSettings);
  }

  Future setString({required String key, required String value}) async {
    SharedPreferences? oldSettings = sharedPreferences;
    await sharedPreferences!.setString(key, value);
    onSettingsUpdateListener?.call(oldSettings);
  }
}
