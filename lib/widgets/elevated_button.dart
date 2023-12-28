import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  const MyElevatedButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}
