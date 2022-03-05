import 'package:flutter/material.dart';
import 'package:lift_tracker/data/helper.dart';
import 'package:lift_tracker/ui/colors.dart';
import 'package:lift_tracker/ui/widgets.dart';

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
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: Container(
          height: 6,
          width: 60,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Palette.elementsDark,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: FittedBox(
              child: Icon(
            isOpen ? Icons.more_horiz : Icons.person,
            color: Colors.white,
          ))),
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
        Helper.unfocusTextFields(context);
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
                            duration: const Duration(milliseconds: 150),
                            maxAlpha: 200,
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
        duration: const Duration(milliseconds: 150),
        opacity: menuOpacity,
        child: Container(
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.maybePop(context);
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildMenuElement("Me", Icons.person, style),
                    SizedBox(
                      height: 16,
                    ),
                    buildMenuElement("Settings", Icons.settings, style),
                    SizedBox(
                      height: 16,
                    ),
                    buildMenuElement("Help", Icons.help, style)
                  ]),
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Palette.elementsDark.withAlpha(120)),
        ),
      ),
    );
  }

  Widget buildMenuElement(String text, IconData icon, TextStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: style,
        ),
        Spacer(),
        Icon(
          icon,
          color: Colors.white,
        )
      ],
    );
  }
}
