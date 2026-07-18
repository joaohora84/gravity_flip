import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'game/gravity_flip_game.dart';
import 'leaderboard/leaderboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Firebase.initializeApp();

  runApp(const GravityFlipApp());
}

class GravityFlipApp extends StatelessWidget {
  const GravityFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gravity Flip',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const _GameScreen(),
    );
  }
}

class _GameScreen extends StatefulWidget {
  const _GameScreen();

  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  late final GravityFlipGame _game;

  @override
  void initState() {
    super.initState();
    _game = GravityFlipGame();
  }

  @override
  Widget build(BuildContext context) {
    _game.strings = AppLocalizations.of(context)!;

    return GameWidget<GravityFlipGame>(
      game: _game,
      overlayBuilderMap: {
        LeaderboardScreen.id: (_, game) => LeaderboardScreen(game: game),
        NameEntryOverlay.id: (_, game) => NameEntryOverlay(game: game),
      },
    );
  }
}
