import 'package:among_us_irl/providers/current_game_provider.dart';
import 'package:among_us_irl/widgets/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeetingScreen extends ConsumerStatefulWidget {
  const MeetingScreen({super.key});

  static const routeName = '/meeting';

  @override
  ConsumerState<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends ConsumerState<MeetingScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen(currentGameProvider, (prev, next) {
      if (prev?.meeting != null && next.meeting == null) {
        Navigator.of(context).pop();
      }
    });
    final String calledBy =
        ModalRoute.of(context)!.settings.arguments as String;
    final bool admin = ref.read(currentGameProvider.notifier).isAdmin();
    final List alive = ref.read(currentGameProvider).alive;
    return Scaffold(
      appBar: AppBar(
        title: Text('Called by: $calledBy'),
      ),
      body: admin
          ? Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Material(
                    child: ListView.builder(
                      shrinkWrap: false,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          tileColor: selectedIndex == index
                              ? Colors.red
                              : Colors.white,
                          title: Text(alive[index]),
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                        );
                      },
                      itemCount: alive.length,
                    ),
                  ),
                ),
                MyElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(currentGameProvider.notifier)
                          .killPlayer(alive[selectedIndex]);
                      await ref.read(currentGameProvider.notifier).endMeeting();
                    },
                    text: 'Confirm ejection'),
                MyElevatedButton(onPressed: () async {await ref.read(currentGameProvider.notifier).endMeeting();}, text: 'Dont eject anyone'),
              ],
            )
          : const Text('Waiting for the admin to decide'),
    );
  }
}
