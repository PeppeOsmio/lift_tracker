import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetRow extends StatefulWidget {
  const SetRow(this.rowIndex,
      {required this.repsController,
      required this.weightController,
      required this.rpeController,
      required this.exerciseType,
      Key? key})
      : super(key: key);
  final int rowIndex;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final TextEditingController rpeController;
  final String exerciseType;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 24,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${widget.rowIndex}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 31, 31),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    keyboardType: TextInputType.number,
                    controller: widget.repsController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: 'Reps',
                      border: InputBorder.none,
                    ),
                  )),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 31, 31),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    controller: widget.weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    readOnly: widget.exerciseType == 'free' ? true : false,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        decoration: widget.exerciseType == 'free'
                            ? TextDecoration.lineThrough
                            : null,
                        decorationThickness: 2,
                      ),
                      hintText: 'Kg',
                      border: InputBorder.none,
                    ),
                  )),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 31, 31),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      onEditingComplete: () {
                        String text = widget.rpeController.text;
                        if (text != '' && int.parse(text) > 10) {
                          widget.rpeController.text = '10';
                        }
                        var currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      controller: widget.rpeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Rpe',
                        border: InputBorder.none,
                      ))),
            ),
          )
        ],
      ),
    );
  }
}
