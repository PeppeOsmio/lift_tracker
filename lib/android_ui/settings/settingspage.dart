import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lift_tracker/android_ui/settings/settings.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> settings = {};

  @override
  void initState() {
    super.initState();
    SharedPreferences sharedPreferences = Settings.instance.sharedPreferences!;
    settings.addEntries([
      {'useMaterial3': sharedPreferences.getBool('useMaterial3') ?? false}
          .entries
          .first,
      {
        'useSystemPalette':
            sharedPreferences.getBool('useSystemPalette') ?? false
      }.entries.first,
      {
        'mainColor':
            sharedPreferences.getInt('mainColor') ?? Colors.orange.value
      }.entries.first
    ]);
  }

  @override
  Widget build(BuildContext context) {
    SettingsThemeData settingsThemeData = SettingsThemeData(
        leadingIconsColor: Theme.of(context).colorScheme.onBackground,
        tileDescriptionTextColor: Theme.of(context).colorScheme.onSurface,
        titleTextColor: Theme.of(context).colorScheme.onBackground,
        settingsListBackground: Theme.of(context).colorScheme.background);
    return Scaffold(
      appBar: AppBar(
        title: Text(UIUtilities.loadTranslation(context, 'settings')),
      ),
      body: SettingsList(
        lightTheme: settingsThemeData,
        darkTheme: settingsThemeData,
        sections: [
          SettingsSection(
            title: Text('Theming'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                activeSwitchColor: Theme.of(context).colorScheme.primary,
                onToggle: (value) {
                  Settings.instance.setBool(key: 'useMaterial3', value: value);
                  settings['useMaterial3'] = value;
                },
                initialValue: settings['useMaterial3'],
                leading: Icon(Icons.brush),
                title: Text('Material 3 theme'),
              ),
              SettingsTile.switchTile(
                activeSwitchColor: Theme.of(context).colorScheme.primary,
                onToggle: (value) {
                  Settings.instance
                      .setBool(key: 'useSystemPalette', value: value);
                  settings['useSystemPalette'] = value;
                },
                initialValue: settings['useSystemPalette'],
                leading: Icon(Icons.palette),
                title: Text('Use system color palette'),
              ),
              SettingsTile.navigation(
                enabled: !settings['useSystemPalette'],
                title: Text('Main color'),
                leading: Icon(Icons.colorize),
                description: Text(Color(settings['mainColor']).toString()),
                onPressed: (context) async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            'Pick a color',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                          ),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                                labelTypes: [
                                  ColorLabelType.rgb,
                                  ColorLabelType.hex
                                ],
                                pickerColor:
                                    Theme.of(context).colorScheme.primary,
                                onColorChanged: (color) {
                                  settings['mainColor'] = color.value;
                                }),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Settings.instance.setInt(
                                      key: 'mainColor',
                                      value: settings['mainColor']);
                                  Navigator.pop(context);
                                },
                                child: Text('Done'))
                          ],
                        );
                      });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
