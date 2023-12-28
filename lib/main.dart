import 'package:among_us_irl/screens/create_game_screen.dart';
import 'package:among_us_irl/screens/crewmate_screen.dart';
import 'package:among_us_irl/screens/crewmates_win_screen.dart';
import 'package:among_us_irl/screens/death_screen.dart';
import 'package:among_us_irl/screens/impostor_screen.dart';
import 'package:among_us_irl/screens/impostors_win_screen.dart';
import 'package:among_us_irl/screens/join_game_screen.dart';
import 'package:among_us_irl/screens/meeting_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const JoinGameScreen(),
      routes: {
        JoinGameScreen.routeName: (context) => const JoinGameScreen(),
        CreateGameScreen.routeName: (context) => const CreateGameScreen(),
        CrewmateScreen.routeName: (context) => const CrewmateScreen(),
        ImpostorScreen.routeName: (context) => const ImpostorScreen(),
        DeathScreen.routeName: (context) => const DeathScreen(),
        CrewmatesWinScreen.routeName: (context) => const CrewmatesWinScreen(),
        ImpostorsWinScreen.routeName: (context) => const ImpostorsWinScreen(),
        MeetingScreen.routeName: (context) => const MeetingScreen(),
      },
    );
  }
}
