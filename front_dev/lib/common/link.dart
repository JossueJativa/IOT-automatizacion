import 'package:flutter/material.dart';

class Link extends StatelessWidget {
  final String text;
  final String url;

  const Link({super.key, required this.text, required this.url});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {
        Navigator.popAndPushNamed(context, url),
      },
      child: Text(text),
    );
  }
}
