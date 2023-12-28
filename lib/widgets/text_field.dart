import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String text;

  const MyTextField({super.key, required this.controller, required this.text});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {

  late final TextEditingController _controller;
  late final String _text;

  @override
  void initState() {
    _controller = widget.controller;
    _text = widget.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: _text,
        border: const OutlineInputBorder()
      ),
    );
  }
}
