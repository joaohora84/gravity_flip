import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

import '../game/components/ground.dart';
import '../game/gravity_flip_game.dart';
import 'best_score_display.dart';
import 'score_display.dart';

class Hud extends PositionComponent with HasGameReference<GravityFlipGame> {
  late final ScoreDisplay _scoreDisplay;
  late final BestScoreDisplay _bestDisplay;
  late final TextComponent _powerUpLabel;

  @override
  Future<void> onLoad() async {
    const topPad = Ground.thickness + 14.0;

    _scoreDisplay = ScoreDisplay()
      ..position = Vector2(game.size.x / 2, topPad);

    _bestDisplay = BestScoreDisplay()
      ..position = Vector2(16, topPad + 4);

    _powerUpLabel = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFEE58),
          fontSize: 13,
          letterSpacing: 1.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topRight,
      position: Vector2(game.size.x - 16, topPad + 4),
    );

    await add(_scoreDisplay);
    await add(_bestDisplay);
    await add(_powerUpLabel);
  }

  @override
  void update(double dt) {
    final s = game.strings;
    final parts = <String>[];
    if (game.hasShield) parts.add(s?.shieldActive ?? 'SHIELD');
    if (game.isDoubleScore) parts.add(s?.doubleScoreActive ?? '2X');
    if (game.isSlowMotion) parts.add(s?.slowMotionActive ?? 'SLOW');
    _powerUpLabel.text = parts.join('  ');
  }

  void updateScore(int score) => _scoreDisplay.setScore(score);

  void updateBest(int best) => _bestDisplay.setBest(best);
}
