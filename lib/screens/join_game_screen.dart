import 'package:among_us_irl/providers/current_game_provider.dart';
import 'package:among_us_irl/screens/connection_successful_screen.dart';
import 'package:among_us_irl/screens/create_game_screen.dart';
import 'package:among_us_irl/widgets/text_field.dart';
import 'package:among_us_irl/widgets/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  static const routeName = '/join_game';

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gameIdController = TextEditingController();
  String? nameErrorText;
  String? codeErrorText;

  @override
  void initState() {
    nameErrorText = '';
    codeErrorText = '';
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gameIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MyTextField(
                  controller: _nameController,
                  text: 'Name',
                  errorText: nameErrorText!,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                ),
                MyElevatedButton(
                    onPressed: () async {
                      String? name = _nameController.text;
                      if (name.isNotEmpty) {
                        await ref.read(currentGameProvider.notifier).createGame(name);
                        Navigator.pushNamed(context, CreateGameScreen.routeName);
                      } setState(() {
                        nameErrorText = 'Please enter a name';
                      });
                    },
                    text: 'Create game'),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                ),
                MyTextField(
                  controller: _gameIdController,
                  text: 'Game code',
                  errorText: codeErrorText!,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                ),
                MyElevatedButton(
                    onPressed: () async {
                      String? code = _gameIdController.text.toUpperCase();
                      String? name = _nameController.text;
                      if (await ref
                          .read(currentGameProvider.notifier)
                          .codeValid(code)) {
                        if (name.isNotEmpty) {
                          if (name.length < 20) {
                            await ref
                                .read(currentGameProvider.notifier)
                                .joinGame(code, name);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ConnectionSuccessfulScreen(
                                            gameCode: code)));
                          }
                          setState(() {
                            nameErrorText = 'Name too long';
                          });
                        }
                        setState(() {
                          nameErrorText = 'Please enter a name';
                        });
                      }
                      setState(() {
                        codeErrorText = 'Invalid code';
                      });
                    },
                    text: 'Join game'),
              ],
            );
          },
        ),
      ),
    );
  }
}
