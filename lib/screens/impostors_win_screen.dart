import 'package:among_us_irl/screens/join_game_screen.dart';
import 'package:among_us_irl/widgets/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/current_game_provider.dart';
import 'create_game_screen.dart';
import 'crewmate_screen.dart';
import 'impostor_screen.dart';

class ImpostorsWinScreen extends ConsumerWidget {
  const ImpostorsWinScreen({super.key});

  static const routeName = '/impostors_win';

  final bool admin = true;

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
    final bool admin = ref.read(currentGameProvider.notifier).isAdmin();
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Text('COMMON IMPOSTOR W'),
          Image.asset('assets/images/smile.png'),
          MyElevatedButton(
              onPressed: () async {
                await ref.read(currentGameProvider.notifier).deletePlayer();
                Navigator.pushNamed(context, JoinGameScreen.routeName);
              },
              text: 'Leave game'),
          if (admin)
            MyElevatedButton(
              onPressed: () async {
                await ref.read(currentGameProvider.notifier).resetGame();
                Navigator.of(context).pushNamed(CreateGameScreen.routeName);
              },
              text: 'To game menu',
            )
        ],
      ),
    );
  }
}
