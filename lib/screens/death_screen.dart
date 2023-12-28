import 'package:among_us_irl/widgets/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/current_game_provider.dart';
import 'crewmates_win_screen.dart';
import 'impostors_win_screen.dart';
import 'join_game_screen.dart';

class DeathScreen extends ConsumerWidget {
  const DeathScreen({super.key});

  static const routeName = '/death';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentGameProvider, (prev, next) async {
      if (prev?.crewmatesWin == false && next.crewmatesWin == true) {
        Navigator.of(context).pushNamed(CrewmatesWinScreen.routeName);
      }
      if (prev?.impostorsWin == false && next.impostorsWin == true) {
        Navigator.of(context).pushNamed(ImpostorsWinScreen.routeName);
      }
    });
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Text('R.I.P.'),
          Image.asset('assets/images/andrew-tate-bottom-g.gif'),
          MyElevatedButton(onPressed: () async {
            await ref.read(currentGameProvider.notifier).deletePlayer();
            Navigator.pushNamed(context, JoinGameScreen.routeName);
          }, text: 'Leave game')
        ],
      )
    );
  }
}
