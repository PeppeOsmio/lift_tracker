import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/android_ui/uiutilities.dart';
import 'package:lift_tracker/data/backup.dart';
import 'package:lift_tracker/data/database/database.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/old_ui/profile/profile.dart';
import 'package:lift_tracker/old_ui/styles.dart';
import 'package:lift_tracker/old_ui/widgets.dart';
import 'package:restart_app/restart_app.dart';

class BlurredProfileMenu extends StatefulWidget {
  const BlurredProfileMenu({Key? key}) : super(key: key);

  @override
  BlurredProfileMenuState createState() => BlurredProfileMenuState();
}

class BlurredProfileMenuState extends State<BlurredProfileMenu> {
  GlobalKey containerKey = GlobalKey();
  double menuOpacity = 0;

  Offset getOffset(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    double dy = renderBox.localToGlobal(Offset.zero).dy;
    double dx = renderBox.localToGlobal(Offset.zero).dx;
    return Offset(dx, dy);
  }

  Size getSize(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size;
  }

  Widget button(bool isOpen) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 20, bottom: 4),
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(1.0, 1.0)),
              ],
              color: Palette.elementsDark,
              borderRadius: const BorderRadius.all(Radius.circular(17.5))),
          child: FittedBox(
            child: Icon(isOpen ? Icons.more_horiz : Icons.person,
                color: Colors.white, size: 20),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(key: containerKey, child: button(false)),
      onTap: () {
        UIUtilities.unfocusTextFields(context);
        PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, _, __) {
              Offset offset = getOffset(containerKey);
              Size size = getSize(containerKey);
              return Material(
                type: MaterialType.transparency,
                child: WillPopScope(
                    onWillPop: () async {
                      return true;
                    },
                    child: Stack(children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.maybePop(context);
                          },
                          child: const DimmingBackground(
                            blurred: true,
                            duration: const Duration(milliseconds: 100),
                            maxAlpha: 130,
                          )),
                      Positioned(
                          top: offset.dy,
                          left: offset.dx,
                          child:
                              //with align and sizedbox we can force the widget to
                              //have a specific size
                              Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                                width: size.width,
                                height: size.height,
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.maybePop(context);
                                    },
                                    child: button(true))),
                          )),
                      Positioned(
                          top: offset.dy + size.height + 16,
                          right: 16,
                          child: AnimatedMenu())
                    ])),
              );
            });
        Navigator.push(context, pageRouteBuilder);
      },
    );
  }
}

class AnimatedMenu extends StatefulWidget {
  const AnimatedMenu({Key? key}) : super(key: key);

  @override
  _AnimatedMenuState createState() => _AnimatedMenuState();
}

class _AnimatedMenuState extends State<AnimatedMenu> {
  double menuOpacity = 0;
  bool isRestoring = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        menuOpacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(color: Colors.white, fontSize: 18);
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          menuOpacity = 0;
        });
        return true;
      },
      child: AnimatedOpacity(
        curve: Curves.decelerate,
        duration: const Duration(milliseconds: 100),
        opacity: menuOpacity,
        child: IntrinsicWidth(
          child: Container(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 8),
              child: Consumer(
                builder: (context, ref, child) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildMenuElement(
                            UIUtilities.loadTranslation(context, 'profile'),
                            Icons.person,
                            style, onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Profile();
                          }));
                        }),
                        buildMenuElement(
                            UIUtilities.loadTranslation(
                                context, 'restoreBackupMenu'),
                            Icons.settings_backup_restore,
                            style, onPressed: () async {
                          await showDimmedBackgroundDialog(context,
                              title: UIUtilities.loadTranslation(
                                  context, 'restoreBackup'),
                              rightText: UIUtilities.loadTranslation(
                                  context, 'cancel'),
                              leftText:
                                  UIUtilities.loadTranslation(context, 'yes'),
                              rightOnPressed: () {
                            if (isRestoring) {
                              return;
                            }
                            Navigator.maybePop(context);
                          }, leftOnPressed: () async {
                            if (isRestoring) {
                              return;
                            }
                            isRestoring = true;
                            var back;
                            await (Backup.readBackup().then((value) {
                              back = value;
                            }).catchError((error) {
                              log('menu: $error');
                              Fluttertoast.showToast(
                                  msg: 'menu: ' + error.toString());
                            }));
                            if (back == null) {
                              Fluttertoast.showToast(
                                  msg: 'menu: Invalid backup.');
                            } else {
                              if (back.isNotEmpty) {
                                Fluttertoast.showToast(
                                    msg: UIUtilities.loadTranslation(
                                        context, 'backupRestored'));
                                Restart.restartApp();
                              } else {
                                Fluttertoast.showToast(
                                    msg: UIUtilities.loadTranslation(
                                        context, 'noBackup'));
                              }
                            }
                            isRestoring = false;
                            Navigator.maybePop(context);
                          });
                          Navigator.maybePop(context);
                        }),
                        buildMenuElement(
                            UIUtilities.loadTranslation(
                                context, 'createBackupMenu'),
                            Icons.save,
                            style, onPressed: () async {
                          await showDimmedBackgroundDialog(context,
                              title: UIUtilities.loadTranslation(
                                  context, 'createBackup'),
                              rightText: UIUtilities.loadTranslation(
                                  context, 'cancel'),
                              leftText:
                                  UIUtilities.loadTranslation(context, 'yes'),
                              rightOnPressed: () => Navigator.maybePop(context),
                              leftOnPressed: () async {
                                bool created = false;
                                await Backup.createBackup().catchError((error) {
                                  Fluttertoast.showToast(
                                      msg: 'menu: ' + error.toString());
                                });
                                if (created) {
                                  Fluttertoast.showToast(
                                      msg: UIUtilities.loadTranslation(
                                          context, 'createdBackup'));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: UIUtilities.loadTranslation(
                                          context, 'didntCreateBackup'));
                                }
                                Navigator.maybePop(context);
                              });
                          Navigator.maybePop(context);
                        }),
                        buildMenuElement(
                            UIUtilities.loadTranslation(context, 'help'),
                            Icons.help,
                            style,
                            onPressed: () => Navigator.maybePop(context))
                      ]);
                },
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Palette.elementsDark.withAlpha(120)),
          ),
        ),
      ),
    );
  }

  Widget buildMenuElement(String text, IconData icon, TextStyle style,
      {Function? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onPressed != null) {
            onPressed();
          }
        },
        child: Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                text,
                style: style,
              ),
              SizedBox(width: 8),
              Spacer(),
              Icon(
                icon,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
