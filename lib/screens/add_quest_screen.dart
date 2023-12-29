import 'package:among_us_irl/providers/current_game_provider.dart';
import 'package:among_us_irl/widgets/elevated_button.dart';
import 'package:among_us_irl/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddQuestScreen extends StatefulWidget {
  final String gameCode;

  const AddQuestScreen({super.key, required this.gameCode});

  @override
  State<AddQuestScreen> createState() => _AddQuestScreenState();
}

class _AddQuestScreenState extends State<AddQuestScreen> {
  final TextEditingController _questController = TextEditingController();
  late final String _gameCode;
  String errorText = '';

  @override
  void initState() {
    _gameCode = widget.gameCode;
    super.initState();
  }

  @override
  void dispose() {
    _questController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gameCode),
      ),
      body: Column(
        children: <Widget>[
          MyTextField(controller: _questController, text: 'Quest', errorText: errorText,),
          Consumer(
            builder: (context, ref, child) {
              return MyElevatedButton(
                  onPressed: () async {
                    if (_questController.text.isNotEmpty) {
                      await ref
                          .read(currentGameProvider.notifier)
                          .addQuest(_questController.text);
                      _questController.text = '';
                    } setState(() {
                      errorText = 'Please enter a quest name';
                    });
                  },
                  text: 'Add Quest');
            },
          ),
        ],
      ),
    );
  }
}
