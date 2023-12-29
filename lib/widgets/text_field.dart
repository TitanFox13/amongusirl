import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String text;
  final String errorText;

  const MyTextField({super.key, required this.errorText, required this.controller, required this.text});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {

  late final TextEditingController _controller;
  String? _text;
  String? _errorText;

  @override
  void initState() {
    _controller = widget.controller;
    _text = widget.text;
    _errorText = widget.errorText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _errorText = widget.errorText;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.deepOrange),
        ),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          controller: _controller,
          decoration: InputDecoration(
            errorText: _errorText!.isNotEmpty ? _errorText : null,
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 0)),
            labelStyle: const TextStyle(
              color: Colors.white
            ),
            labelText: _text,
            border: const OutlineInputBorder()
          ),
        ),
      ),
    );
  }
}
