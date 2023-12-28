import 'package:among_us_irl/screens/crewmates_win_screen.dart';
import 'package:among_us_irl/screens/death_screen.dart';
import 'package:among_us_irl/screens/impostors_win_screen.dart';
import 'package:among_us_irl/screens/meeting_screen.dart';
import 'package:among_us_irl/widgets/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/current_game_provider.dart';

class CrewmateScreen extends ConsumerStatefulWidget {
  const CrewmateScreen({super.key});

  static const routeName = '/crewmate';

  @override
  ConsumerState<CrewmateScreen> createState() => _CrewmateScreenState();
}

class _CrewmateScreenState extends ConsumerState<CrewmateScreen> {
  late List<bool> checked;
  late Future<Map> playerQuests;

  @override
  void initState() {
    checked = [];
    playerQuests = ref.read(currentGameProvider.notifier).getPlayerQuests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentGameProvider, (prev, next) {
      if (prev?.meeting == null && next.meeting != null) {
        Navigator.of(context).pushNamed(MeetingScreen.routeName, arguments: next.meeting);
      }
      if (prev?.alive != next.alive) {
        String name = ref.read(currentGameProvider.notifier).getPlayerName();
        if (!next.alive.contains(name)) {
          Navigator.of(context).pushNamed(DeathScreen.routeName);
        }
      }
      if (prev?.crewmatesWin == false && next.crewmatesWin == true) {
        Navigator.of(context).pushNamed(CrewmatesWinScreen.routeName);
      }
      if (prev?.impostorsWin == false && next.impostorsWin == true) {
        Navigator.of(context).pushNamed(ImpostorsWinScreen.routeName);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crewmate'),
        leading: const Text('*'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: FutureBuilder(
                future: playerQuests,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map questsMap = snapshot.data!;
                    List quests = questsMap.keys.toList();
                    for (var quest in questsMap.keys) {
                      checked.add(questsMap[quest] ? true : false);
                    }
                    return ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          value: checked[index],
                          onChanged: (bool? value) async {
                            if (value == true) {
                              await ref
                                  .read(currentGameProvider.notifier)
                                  .completePlayerQuest(quests[index]);
                            } else {
                              await ref
                                  .read(currentGameProvider.notifier)
                                  .uncompletePlayerQuest(quests[index]);
                            }
                            setState(() {
                              checked[index] = value!;
                            });
                          },
                          title: Text(quests[index]),
                        );
                      },
                      itemCount: quests.length,
                    );
                  } else {return const CircularProgressIndicator();}
                }
                ),
          ),
          MyElevatedButton(
              onPressed: () async {
                await ref.read(currentGameProvider.notifier).callMeeting();
              },
              text: 'Emergency meeting/Report body'),
        ],
      ),
    );
  }
}
