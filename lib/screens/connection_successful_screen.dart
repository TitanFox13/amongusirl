import 'package:among_us_irl/providers/current_game_provider.dart';
import 'package:among_us_irl/screens/impostor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crewmate_screen.dart';

class ConnectionSuccessfulScreen extends ConsumerWidget {
  final String gameCode;
  const ConnectionSuccessfulScreen({super.key, required this.gameCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.listen(currentGameProvider, (prev, next) async {
      if (prev?.running == false && next.running == true) {
        String name = ref.read(currentGameProvider.notifier).getPlayerName();
        List impostors = await ref.read(currentGameProvider.notifier).getImpostors();
        if (impostors.contains(name)) {
          Navigator.of(context).pushNamed(ImpostorScreen.routeName);
        } else {
          Navigator.of(context).pushNamed(CrewmateScreen.routeName);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(gameCode),
        leading: BackButton(
          onPressed: () async {
            await ref.read(currentGameProvider.notifier).deletePlayer();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          const Text('Connection Succesful'),
          const Text('Waiting for the game to start'),
          Image.asset('assets/images/andrew-tate-bottom-g.gif')
        ],
      ),
    );
  }
}
