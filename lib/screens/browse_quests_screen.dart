import 'package:among_us_irl/providers/current_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrowseQuestsScreen extends ConsumerStatefulWidget {
  const BrowseQuestsScreen({super.key});

  @override
  ConsumerState<BrowseQuestsScreen> createState() => _BrowseQuestsScreenState();
}

class _BrowseQuestsScreenState extends ConsumerState<BrowseQuestsScreen> {
  late List<bool> checked;
  late final Future<List> quests;
  late List gameQuests;

  @override
  void initState() {
    checked = [];
    quests = ref.read(currentGameProvider.notifier).getQuests();
    gameQuests = ref.read(currentGameProvider).quests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.read(currentGameProvider.notifier).getTitle()),
      ),
      body: FutureBuilder(
          future: quests,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List questsList = snapshot.data as List;
              for (var quest in questsList) {
                checked.add(gameQuests.contains(quest) ? true : false);
              }
              return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return CheckboxListTile(
                    title: Text(questsList[index]),
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: checked[index],
                    onChanged: (bool? value) async {
                      if (value == true) {
                        await ref
                            .read(currentGameProvider.notifier)
                            .addGameQuest(questsList[index]);
                      } else {
                        await ref
                            .read(currentGameProvider.notifier)
                            .removeGameQuest(questsList[index]);
                      }
                      setState(() {
                        checked[index] = value!;
                      });
                    },
                  );
                },
                itemCount: questsList.length,
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }
}
