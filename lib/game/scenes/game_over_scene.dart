import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

import '../gravity_flip_game.dart';
import '../systems/audio_system.dart';

class GameOverScene extends Component with HasGameReference<GravityFlipGame> {
  final int score;
  final int bestScore;
  final bool isNewBest;

  late Rect _playAgainRect;
  late Rect _mainMenuRect;
  TextComponent? _statusLabel;

  GameOverScene({
    required this.score,
    required this.bestScore,
    required this.isNewBest,
  });

  @override
  Future<void> onLoad() async {
    AudioSystem.playMenuMusic();

    final cx = game.size.x / 2;
    final h = game.size.y;
    final s = game.strings;

    await add(TextComponent(
      text: s?.gameOver ?? 'GAME OVER',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFF5252),
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, h * 0.27),
    ));

    await add(TextComponent(
      text: '$score',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 72,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, h * 0.42),
    ));

    if (isNewBest) {
      AudioSystem.playSfx(Sfx.newBest);
      await add(TextComponent(
        text: s?.newBest ?? 'NEW BEST!',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFFEE58),
            fontSize: 15,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(cx, h * 0.53),
      ));
    }

    await add(TextComponent(
      text: '${s?.bestLabel ?? 'BEST'}: $bestScore',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, h * (isNewBest ? 0.58 : 0.53)),
    ));

    _statusLabel = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, h * 0.63),
    );
    await add(_statusLabel!);

    const btnW = 230.0;
    const btnH = 52.0;
    final paY = h * 0.70;
    _playAgainRect = Rect.fromCenter(
      center: Offset(cx, paY),
      width: btnW,
      height: btnH,
    );
    _addButton(
      label: s?.playAgain ?? 'PLAY AGAIN',
      cx: cx, cy: paY, w: btnW, h: btnH,
      color: const Color(0xFF6C63FF),
    );

    final mmY = h * 0.81;
    _mainMenuRect = Rect.fromCenter(
      center: Offset(cx, mmY),
      width: btnW,
      height: btnH,
    );
    _addButton(
      label: s?.mainMenu ?? 'MAIN MENU',
      cx: cx, cy: mmY, w: btnW, h: btnH,
      color: const Color(0xFF2A2A4A),
    );

    if (isNewBest && score > 0) {
      if (game.leaderboardService.hasName) {
        _submitScore();
      } else {
        game.triggerNameEntry(score);
      }
    }
  }

  void _addButton({
    required String label,
    required double cx,
    required double cy,
    required double w,
    required double h,
    required Color color,
  }) {
    add(RectangleComponent(
      position: Vector2(cx - w / 2, cy - h / 2),
      size: Vector2(w, h),
      paint: Paint()..color = color,
    ));
    add(TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, cy),
    ));
  }

  Future<void> _submitScore() async {
    final s = game.strings;
    try {
      await game.leaderboardService.submitScore(score);
      game.analyticsService.logLeaderboardScoreSubmitted(score);
      _statusLabel?.text = s?.submitted ?? '✓ Submitted to leaderboard';
    } catch (_) {
      _statusLabel?.text = s?.submissionFailed ?? 'Submission failed';
      if (_statusLabel != null) {
        _statusLabel!.textRenderer = TextPaint(
          style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12),
        );
      }
    }
  }

  void handleTap(Vector2 pos) {
    AudioSystem.playSfx(Sfx.buttonTap);
    if (_playAgainRect.contains(pos.toOffset())) {
      game.startNewGame();
    } else if (_mainMenuRect.contains(pos.toOffset())) {
      game.showMainMenu();
    }
  }
}
