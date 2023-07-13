import 'package:flutter/material.dart';

class AlertPopUp extends StatelessWidget {
  final String titleAlert;
  final String contentAlert;

  const AlertPopUp(
      {super.key, required this.titleAlert, required this.contentAlert});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titleAlert),
      content: Text(contentAlert),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
