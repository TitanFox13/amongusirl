import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final Function() onPressed;
  final String text;

  const MyElevatedButton(
      {super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 12,
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    const MaterialStatePropertyAll<Color>(Colors.deepOrange),
                shape: MaterialStatePropertyAll<OutlinedBorder>(
                    RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.red, width: 1),
                        borderRadius: BorderRadius.circular(30)))),
            onPressed: onPressed,
            child: FittedBox(fit: BoxFit.cover, child: Text(text))),
      ),
    );
  }
}
