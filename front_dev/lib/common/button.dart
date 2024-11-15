import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final Function onPressed;

  const Button(
      {super.key,
      required this.text,
      required this.color,
      required this.textColor,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(color),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
