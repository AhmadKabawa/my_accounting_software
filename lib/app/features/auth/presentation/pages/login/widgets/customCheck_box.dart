import 'package:flutter/material.dart';

class CustomCheckBox extends StatefulWidget {
  String title;
  bool checkvalue  ;
  void Function(bool? value)  onChanged;
  CustomCheckBox({super.key, required this.title,required this.onChanged,required this. checkvalue});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.checkvalue,
          onChanged: (value) {
            setState(() {
              widget.checkvalue = value!;
            });
           widget.onChanged  (value);
          },
        ),
        Text(widget.title),
      ],
    );
  }
}
