import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final Color labelColor;
  final String placeholder;
  final Icon icon;
  final bool isPassword;
  final TextEditingController controller;

  const Input(
      {super.key,
      required this.placeholder,
      required this.isPassword,
      required this.controller,
      required this.labelColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: placeholder,
        icon: icon,
      ),
    );
  }
}