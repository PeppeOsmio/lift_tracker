import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lift_tracker/android_ui/settings/settings.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/backup.dart';
import 'package:restart_app/restart_app.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Settings settings;
  bool canPop = true;

  @override
  void initState() {
    super.initState();
    settings = Settings.instance;
  }

  @override
  Widget build(BuildContext context) {
    SettingsThemeData settingsThemeData = SettingsThemeData(
        leadingIconsColor: Theme.of(context).colorScheme.onBackground,
        tileDescriptionTextColor: Theme.of(context).colorScheme.onSurface,
        titleTextColor: Theme.of(context).colorScheme.onBackground,
        settingsListBackground: Theme.of(context).colorScheme.background);
    return WillPopScope(
      onWillPop: () async {
        log(canPop.toString());
        return canPop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(UIUtilities.loadTranslation(context, 'settings')),
        ),
        body: SettingsList(
          lightTheme: settingsThemeData,
          darkTheme: settingsThemeData,
          sections: [
            SettingsSection(
              title: Text('Backup and restore'),
              tiles: [
                SettingsTile.navigation(
                  title: Text('Create a backup'),
                  leading: Icon(Icons.save),
                  description: settings.backupPath != null
                      ? Text(settings.backupPath!)
                      : null,
                  onPressed: (context) async {
                    setState(() {
                      canPop = false;
                    });
                    showDialog(
                        useRootNavigator: false,
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: SingleChildScrollView(
                              child: Center(
                                  child: CircularProgressIndicator.adaptive()),
                            ),
                          );
                        });
                    try {
                      String? backupPath = await Backup.createBackup();
                      if (backupPath != null) {
                        settings.setBackupPath(backupPath);
                      }
                    } catch (error) {
                      UIUtilities.showSnackBar(
                          context: context,
                          msg:
                              'App needs storage permission to create backups');
                    }
                    setState(() {
                      canPop = true;
                    });
                    Navigator.pop(context);
                  },
                ),
                SettingsTile.navigation(
                  title: Text('Restore a backup'),
                  leading: Icon(Icons.restore),
                  onPressed: (context) async {
                    setState(() {
                      canPop = false;
                    });
                    showDialog(
                        useRootNavigator: false,
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: SingleChildScrollView(
                              child: Center(
                                  child: CircularProgressIndicator.adaptive()),
                            ),
                          );
                        });
                    try {
                      await Backup.readBackup();

                      Restart.restartApp();
                    } catch (error) {
                      log(error.toString());

                      if (error.toString() == 'Exception: permission_denied') {
                        UIUtilities.showSnackBar(
                            context: context,
                            msg:
                                'App needs storage permission to create backups');
                      } else if (error.toString() ==
                          'Exception: backup_canceled') {
                      } else {
                        UIUtilities.showSnackBar(
                            context: context, msg: 'Invalid backup');
                      }
                    }
                    setState(() {
                      canPop = true;
                    });
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            SettingsSection(
              title: Text('Theming'),
              tiles: [
                SettingsTile.switchTile(
                  activeSwitchColor: Theme.of(context).colorScheme.primary,
                  onToggle: (value) {
                    settings.setUseMaterial3(value);
                  },
                  initialValue: settings.useMaterial3,
                  leading: Icon(Icons.brush),
                  title: Text('Material 3 theme'),
                ),
                SettingsTile.switchTile(
                  activeSwitchColor: Theme.of(context).colorScheme.primary,
                  onToggle: (value) {
                    settings.setUseSystemPalette(value);
                  },
                  initialValue: settings.useSystemPalette,
                  leading: Icon(Icons.palette),
                  title: Text('Use system color palette'),
                ),
                SettingsTile.navigation(
                  enabled: !settings.useSystemPalette,
                  title: Text('Main color'),
                  leading: Icon(Icons.colorize),
                  description: Row(
                    children: [
                      Container(
                        width: Theme.of(context).textTheme.bodyText2!.fontSize,
                        height: Theme.of(context).textTheme.bodyText2!.fontSize,
                        decoration: BoxDecoration(
                            color: settings.mainColor,
                            borderRadius: BorderRadius.circular(0)),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                          '#${settings.mainColor.value.toRadixString(16).toUpperCase()}'),
                    ],
                  ),
                  onPressed: (context) async {
                    Color tmpColor = settings.mainColor;
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
                                  pickerColor: settings.mainColor,
                                  onColorChanged: (color) {
                                    tmpColor = color;
                                  }),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Settings.instance.setMainColor(tmpColor);
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
      ),
    );
  }
}
