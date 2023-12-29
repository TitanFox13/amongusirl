import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/get_random_string.dart';

class CurrentGameNotifier extends Notifier<Game> {
  final DatabaseReference _questsRef = FirebaseDatabase.instance.ref('quests');
  late DatabaseReference _dbRef;
  late String _title;
  late String _playerName;
  late bool _isAdmin;

  @override
  Game build() {
    return const Game(
        running: false,
        quests: [],
        meeting: null,
        crewmatesWin: false,
        impostorsWin: false,
        alive: []);
  }

  String getPlayerName() => _playerName;

  Future<void> createGame(String name) async {
    _title = getRandomString(4);
    _dbRef = FirebaseDatabase.instance.ref('games/$_title');
    _playerName = name;
    _isAdmin = true;
    await _dbRef.set({
      'impostor_count': 1,
      'number_of_quests': 1,
      'crewmates_win': false,
      'impostors_win': false,
      'meeting': null,
      'players': {
        _playerName: {
          'impostor': false,
          'alive': true,
          'admin': _isAdmin,
          'quests': {},
          'quests_completed': false,
        },
      },
      'quests': {},
      'running': false,
    });
    state = const Game(
        running: false,
        quests: [],
        meeting: null,
        crewmatesWin: false,
        impostorsWin: false,
        alive: []);
    _listenToGame();
  }

  Future<void> joinGame(String code, String name) async {
    _title = code;
    _dbRef = FirebaseDatabase.instance.ref('games/$_title');
    _playerName = name;
    _isAdmin = false;
    final DatabaseReference playerRef = _dbRef.child('players/$_playerName');
    await playerRef.set({
      'impostor': false,
      'alive': true,
      'admin': _isAdmin,
      'quests': {},
      'quests_completed': false,
    });
    const Game game = Game(
        running: false,
        quests: [],
        meeting: null,
        crewmatesWin: false,
        impostorsWin: false,
        alive: []);
    state = game;
    _listenToGame();
  }

  Future<bool> codeValid(String code) async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('games');
    final snapshot = (await ref.child(code).once()).snapshot;
    if (snapshot.exists) return true;
    return false;
  }

  void _listenToGame() {
    _dbRef.onValue.listen(_onNewGameValue);
  }

  void _onNewGameValue(DatabaseEvent event) {
    if (event.snapshot.exists) {
      final Map value = event.snapshot.value as Map;
      final Game game = Game.fromMap(value);
      state = game;
    }
  }

  Future<void> addQuest(String quest) async {
    await _questsRef.update({quest: true});
  }

  Future<void> addGameQuest(String quest) async =>
      await _dbRef.child('quests').update({quest: true});

  Future<void> removeGameQuest(String quest) async =>
      await _dbRef.child('quests/$quest').remove();

  Future<int> getImpostorCount() async {
    DataSnapshot countData =
        (await _dbRef.child('impostor_count').once()).snapshot;
    int count = countData.value as int;
    return count;
  }

  Future<void> increaseImpostorCount() async {
    int count = await getImpostorCount();
    count++;
    await _dbRef.update({'impostor_count': count});
  }

  Future<void> decreaseImpostorCount() async {
    int count = await getImpostorCount();
    if (count > 1) count--;
    await _dbRef.update({'impostor_count': count});
  }

  Future<int> getQuestCount() async {
    DataSnapshot countData =
        (await _dbRef.child('number_of_quests').once()).snapshot;
    print(countData.value);
    int count = countData.value as int;
    return count;
  }

  Future<void> increaseNumberOfQuests() async {
    int count = await getQuestCount();
    count++;
    await _dbRef.update({'number_of_quests': count});
  }

  Future<void> decreaseNumberOfQuests() async {
    int count = await getQuestCount();
    if (count > 1) count--;
    await _dbRef.update({'number_of_quests': count});
  }

  Future<void> startGame() async {
    final DataSnapshot snapshot = (await _dbRef.once()).snapshot;
    final Map data = snapshot.value as Map;
    final List players = (data['players'] as Map).keys.toList();
    final List quests = (data['quests'] as Map).keys.toList();
    final int impostorCount = data['impostor_count'];
    final int numberOfQuests = data['number_of_quests'];
    final List randomPlayers = players.toList()..shuffle();
    for (String player in randomPlayers.take(impostorCount)) {
      await _dbRef.child('players/$player').update({
        'impostor': true,
        'quests_completed': true,
      });
    }
    for (String player in randomPlayers.skip(impostorCount)) {
      List playerQuests =
          (quests.toList()..shuffle()).take(numberOfQuests).toList();
      Map questsMap = {};
      for (String quest in playerQuests) {
        questsMap[quest] = false;
      }
      await _dbRef.child('players/$player').update({
        'impostor': false,
        'quests': questsMap,
      });
    }
    await _dbRef.update({'running': true});
  }

  Future<List> getQuests() async {
    final DataSnapshot questSnapshot = (await _questsRef.once()).snapshot;
    if (questSnapshot.exists) {
      final Map questsMap = questSnapshot.value as Map;
      final List quests = questsMap.keys.toList();
      return quests;
    }
    return [];
  }

  Future<void> callMeeting() async {
    await _dbRef.update({'meeting': _playerName});
  }

  Future<void> endMeeting() async {
    await _dbRef.update({'meeting': null});
  }

  Future<void> killPlayer(String player) async {
    await _dbRef.child('players/$player').update({'alive': false});
    await checkForKillWin();
  }

  Future<void> completePlayerQuest(String quest) async {
    await _dbRef.child('players/$_playerName/quests').update({quest: true});
    Map quests = await getPlayerQuests();
    List completed = [];
    for (bool done in quests.values) {
      if (done == true) {
        completed.add(done);
      }
    }
    if (completed.length == quests.values.length) {
      await _dbRef
          .child('players/$_playerName')
          .update({'quests_completed': true});
    }
    await checkForQuestWin();
  }

  Future<void> uncompletePlayerQuest(String quest) async {
    await _dbRef.child('players/$_playerName/quests').update({quest: false});
  }

  Future<void> checkForQuestWin() async {
    DataSnapshot snapshot = (await _dbRef.child('players').once()).snapshot;
    Map players = snapshot.value as Map;
    List completed = [];
    for (String player in state.alive) {
      if (players[player]['quests_completed'] == true) {
        completed.add(players);
      }
    }
    if (completed.length == state.alive.length) {
      await _dbRef.update({'crewmates_win': true, 'running': false});
    }
  }

  Future<void> checkForKillWin() async {
    List impostors = await getImpostors();
    DataSnapshot countSnapshot =
        (await _dbRef.child('impostor_count').once()).snapshot;
    int impostorCount = countSnapshot.value as int;
    List aliveImpostors = [];
    for (String impostor in impostors) {
      DataSnapshot snapshot =
          (await _dbRef.child('players/$impostor/alive').once()).snapshot;
      bool alive = snapshot.value as bool;
      if (alive == true) aliveImpostors.add(impostor);
    }
    if ((state.alive.length - aliveImpostors.length) <= impostorCount) {
      await _dbRef.update({'impostors_win': true, 'running': false});
    }
  }

  Future<Map> getPlayerQuests() async {
    DataSnapshot snapshot =
        (await _dbRef.child('players/$_playerName/quests').once()).snapshot;
    Map quests = snapshot.value as Map;
    return quests;
  }

  Future<List> getImpostors() async {
    DataSnapshot snapshot = (await _dbRef.child('players').once()).snapshot;
    Map playersMap = snapshot.value as Map;
    List<String> impostors = [];
    for (String player in playersMap.keys) {
      if (playersMap[player]['impostor'] == true) impostors.add(player);
    }
    return impostors;
  }

  String getTitle() => _title;

  Future<void> deletePlayer() async {
    await _dbRef.child('players/$_playerName').remove();
  }

  bool isAdmin() => _isAdmin;

  Future<void> resetGame() async {
    await _dbRef.set({
      'crewmates_win': false,
      'impostors_win': false,
      'meeting': null,
      'running': false,
    });
    DataSnapshot snapshot = (await _dbRef.child('players').once()).snapshot;
    List players = (snapshot.value as Map).keys.toList();
    for (String player in players) {
      await _dbRef.child('players/$player').update({
        'impostor': false,
        'alive': true,
        'quests': {},
        'quests_completed': false,
      });
    }
  }
}

final currentGameProvider =
    NotifierProvider<CurrentGameNotifier, Game>(CurrentGameNotifier.new);

class Game {
  final List quests;
  final String? meeting;
  final bool crewmatesWin;
  final bool impostorsWin;
  final List<String> alive;
  final bool running;

  const Game({
    required this.quests,
    required this.meeting,
    required this.crewmatesWin,
    required this.impostorsWin,
    required this.alive,
    required this.running,
  });

  factory Game.fromMap(Map data) {
    List<String> alive = [];
    Map players = data['players'];
    for (String player in players.keys) {
      if (players[player]!['alive'] == true) {
        alive.add(player);
      }
    }

    final List quests;
    if (data['quests'] != null) {
      Map questsMap = data['quests'];
      quests = questsMap.keys.toList();
    } else {
      quests = [];
    }

    return Game(
      quests: quests,
      meeting: data['meeting'],
      crewmatesWin: data['crewmates_win'],
      impostorsWin: data['impostors_win'],
      alive: alive,
      running: data['running'],
    );
  }
}

// meeting (str), crew_win (bool), imp_win (bool), quests (list)
