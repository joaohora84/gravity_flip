import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

import '../gravity_flip_game.dart';
import '../systems/audio_system.dart';

class MainMenu extends Component with HasGameReference<GravityFlipGame> {
  late final TextPaint _tapBright;
  late final TextPaint _tapDim;
  late TextComponent _tapLabel;
  double _blinkTimer = 0;

  late Rect _leaderboardRect;

  @override
  Future<void> onLoad() async {
    AudioSystem.playMenuMusic();

    final cx = game.size.x / 2;
    final h = game.size.y;
    final s = game.strings;

    _tapBright = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 16,
        letterSpacing: 4,
        fontWeight: FontWeight.w300,
      ),
    );
    _tapDim = TextPaint(
      style: const TextStyle(
        color: Color(0x44FFFFFF),
        fontSize: 16,
        letterSpacing: 4,
        fontWeight: FontWeight.w300,
      ),
    );

    // Game title — brand name, not localized
    await add(TextComponent(
      text: 'GRAVITY',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00D4FF),
          fontSize: 50,
          fontWeight: FontWeight.bold,
          letterSpacing: 6,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, h * 0.30),
    ));
    await add(TextComponent(
      text: 'FLIP',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF6C63FF),
          fontSize: 50,
          fontWeight: FontWeight.bold,
          letterSpacing: 6,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, h * 0.39),
    ));

    _tapLabel = TextComponent(
      text: s?.tapToPlay ?? 'TAP TO PLAY',
      textRenderer: _tapBright,
      anchor: Anchor.center,
      position: Vector2(cx, h * 0.58),
    );
    await add(_tapLabel);

    // Leaderboard button
    const lbW = 190.0;
    const lbH = 44.0;
    final lbY = h * 0.77;
    _leaderboardRect = Rect.fromCenter(
      center: Offset(cx, lbY),
      width: lbW,
      height: lbH,
    );
    await add(RectangleComponent(
      position: Vector2(cx - lbW / 2, lbY - lbH / 2),
      size: Vector2(lbW, lbH),
      paint: Paint()..color = const Color(0xFF1E1E3A),
    ));
    await add(TextComponent(
      text: s?.leaderboard ?? 'LEADERBOARD',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 13,
          letterSpacing: 2,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, lbY),
    ));
  }

  @override
  void update(double dt) {
    _blinkTimer += dt;
    _tapLabel.textRenderer = (_blinkTimer % 1.4) < 0.7 ? _tapBright : _tapDim;
  }

  void handleTap(Vector2 pos) {
    AudioSystem.playSfx(Sfx.buttonTap);
    if (_leaderboardRect.contains(pos.toOffset())) {
      game.showLeaderboard();
    } else {
      game.startNewGame();
    }
  }
}
