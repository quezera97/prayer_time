import 'package:flutter/material.dart';

class LeadIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const LeadIconText({super.key, 
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            child: Icon(
              icon,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
