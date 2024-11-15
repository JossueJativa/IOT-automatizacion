import 'package:flutter/material.dart';
import 'package:front_dev/common/button.dart';

class PopUp extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback pstCallback;
  final VoidCallback ngtCallback;

  const PopUp(
      {super.key,
      required this.title,
      required this.content,
      required this.pstCallback,
      required this.ngtCallback});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.centerLeft,
      title: Text(title),
      content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9, child: content),
      actions: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Button(
            text: 'Aceptar',
            color: Colors.green,
            onPressed: pstCallback,
            textColor: Colors.white,
          ),
          Button(
            text: 'Cancelar',
            color: Colors.red,
            onPressed: ngtCallback,
            textColor: Colors.white,
          ),
        ])
      ],
    );
  }
}
