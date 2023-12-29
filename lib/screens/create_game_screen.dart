import 'package:among_us_irl/providers/current_game_provider.dart';
import 'package:among_us_irl/screens/add_quest_screen.dart';
import 'package:among_us_irl/screens/browse_quests_screen.dart';
import 'package:among_us_irl/widgets/elevated_button.dart';
import 'package:among_us_irl/widgets/increment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crewmate_screen.dart';
import 'impostor_screen.dart';

class CreateGameScreen extends ConsumerWidget {
  const CreateGameScreen({super.key});

  static const routeName = 'create_game';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Game gameInfo = ref.watch(currentGameProvider);
    List quests =
        gameInfo.quests.isNotEmpty ? gameInfo.quests : ['No quests selected'];
    String title = ref.read(currentGameProvider.notifier).getTitle();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  'Quests:',
                  style: TextStyle(color: Colors.deepOrange),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20 , 0, 20, 20),
              child: Material(
                child: ListView.builder(
                  itemCount: quests.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(quests[index]!),
                    );
                  },
                  shrinkWrap: false,
                ),
              ),
            ),
          ),
          MyElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BrowseQuestsScreen()),
                );
              },
              text: 'Browse quests'),
          MyElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddQuestScreen(gameCode: title)),
                );
              },
              text: 'Add quests'),
          Increment(
              text: 'Number of impostors',
              initialValue: 1,
              onPlus: () async {
                await ref
                    .read(currentGameProvider.notifier)
                    .increaseImpostorCount();
              },
              onMinus: () async {
                await ref
                    .read(currentGameProvider.notifier)
                    .decreaseImpostorCount();
              }),
          Increment(
              text: 'Number of quests',
              initialValue: 1,
              onPlus: () async {
                await ref
                    .read(currentGameProvider.notifier)
                    .increaseNumberOfQuests();
              },
              onMinus: () async {
                await ref
                    .read(currentGameProvider.notifier)
                    .decreaseNumberOfQuests();
              }),
          MyElevatedButton(
              onPressed: () async {
                await ref.read(currentGameProvider.notifier).startGame();
                String name =
                    ref.read(currentGameProvider.notifier).getPlayerName();
                List impostors =
                    await ref.read(currentGameProvider.notifier).getImpostors();
                if (impostors.contains(name)) {
                  Navigator.of(context).pushNamed(ImpostorScreen.routeName);
                } else {
                  Navigator.of(context).pushNamed(CrewmateScreen.routeName);
                }
              },
              text: 'Start game'),
        ],
      ),
    );
  }
}
