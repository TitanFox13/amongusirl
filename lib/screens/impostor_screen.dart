import 'dart:async';

import 'package:among_us_irl/widgets/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/current_game_provider.dart';
import 'crewmates_win_screen.dart';
import 'death_screen.dart';
import 'impostors_win_screen.dart';
import 'meeting_screen.dart';

class ImpostorScreen extends ConsumerStatefulWidget {
  const ImpostorScreen({super.key});

  static const routeName = '/impostor';

  @override
  ConsumerState<ImpostorScreen> createState() => _ImpostorScreenState();
}

class _ImpostorScreenState extends ConsumerState<ImpostorScreen> {
  int killCooldown = 0;
  late Future<List> impostors;

  @override
  void initState() {
    impostors = ref.read(currentGameProvider.notifier).getImpostors();
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
          title: const Text('Impostor'),
          leading: const Text('*'),
        ),
        body: FutureBuilder(
            future: impostors,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List impostorsList = snapshot.data!;
                List playersToKill = ref.read(currentGameProvider).alive;
                for (String impostor in impostorsList) {
                  if (playersToKill.contains(impostor)) {
                    playersToKill.remove(impostor);
                  }
                }
                return Column(
                  children: <Widget>[
                    Text('Impostors: ${impostorsList.join(', ')}'),
                    SizedBox(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 2,
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              title: Text(playersToKill[index]),
                              trailing: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    killCooldown = 30;
                                    Timer.periodic(const Duration(seconds: 1),
                                            (timer) {
                                          setState(() {
                                            killCooldown--;
                                          });
                                          if (killCooldown == 0) {
                                            timer.cancel();
                                          }
                                        });
                                    await ref.read(currentGameProvider.notifier).killPlayer(playersToKill[index]);
                                  },
                                  child: Image.asset(
                                    "assets/images/skull.png",
                                  ),
                                ),
                              ));
                        },
                        itemCount: playersToKill.length,
                      ),
                    ),
                    Text('Kill cooldown: $killCooldown'),
                    MyElevatedButton(
                        onPressed: () async {
                          await ref.read(currentGameProvider.notifier).callMeeting();
                        },
                        text: 'Emergency meeting/Report body'),
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            }));
  }
}
