import 'package:flutter/material.dart';

class Increment extends StatefulWidget {
  final String text;
  final int initialValue;
  final Future<void> Function() onPlus;
  final Future<void> Function() onMinus;

  const Increment(
      {super.key,
      required this.text,
      required this.initialValue,
      required this.onPlus,
      required this.onMinus});

  @override
  State<Increment> createState() => _IncrementState();
}

class _IncrementState extends State<Increment> {
  late final String _text;
  late final int _initialValue;
  late final Future<void> Function() _onPlus;
  late final Future<void> Function() _onMinus;
  late int _value;

  @override
  void initState() {
    _text = widget.text;
    _initialValue = widget.initialValue;
    _onPlus = widget.onPlus;
    _onMinus = widget.onMinus;
    _value = _initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('$_text: $_value'),
        IconButton(
          onPressed: () async {
            await _onPlus();
            setState(() {
              _value++;
            });
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () async {
            await _onMinus();
            setState(() {
              if (_value > 1) _value--;
            });
          },
          icon: const Icon(Icons.remove),
        ),
      ],
    );
  }
}
