import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const Label(
      {super.key,
      required this.text,
      required this.color,
      required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
      ),
    );
  }
}
