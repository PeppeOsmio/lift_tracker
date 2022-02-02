import 'package:flutter/material.dart';

class MySmallMaterialButton extends StatefulWidget {
  const MySmallMaterialButton(this.onPressed, this.backgroundColor, this.child,
      {Key? key})
      : super(key: key);
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget child;

  @override
  _MySmallMaterialButtonState createState() => _MySmallMaterialButtonState();
}

class _MySmallMaterialButtonState extends State<MySmallMaterialButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
            height: 20,
            width: 20,
            child: GestureDetector(
                onTap: () => widget.onPressed.call(),
                child: FittedBox(child: widget.child))));
  }
}

class MyMaterialButton extends StatefulWidget {
  const MyMaterialButton(
      this.onPressed, this.backgroundColor, this.icon, this.iconColor,
      {Key? key})
      : super(key: key);
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  _MyMaterialButtonState createState() => _MyMaterialButtonState();
}

class _MyMaterialButtonState extends State<MyMaterialButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
          height: 35,
          width: 35,
          child: InkWell(
              radius: 17.5,
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                widget.onPressed.call();
              },
              child: Icon(
                widget.icon,
                color: widget.iconColor,
              ))),
    );
  }
}
