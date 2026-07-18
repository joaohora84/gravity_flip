import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../gravity_flip_game.dart';

enum PowerUpType { shield, slowMotion, magnet, doubleScore }

class PowerUp extends PositionComponent with HasGameReference<GravityFlipGame> {
  static const double _radius = 20.0;

  final PowerUpType type;
  late final TextPainter _symbolPainter;

  PowerUp({
    required this.type,
    required double spawnX,
    required double spawnY,
  }) : super(
          size: Vector2.all(_radius * 2),
          anchor: Anchor.center,
          position: Vector2(spawnX, spawnY),
        );

  @override
  Future<void> onLoad() async {
    _symbolPainter = TextPainter(
      text: TextSpan(
        text: _symbolFor(type),
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    await add(CircleHitbox.relative(0.9, parentSize: size));
  }

  @override
  void update(double dt) {
    position.x -= game.currentSpeed * dt;
    if (position.x + _radius < 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    const r = _radius;
    const center = Offset(r, r);
    final color = _colorFor(type);
    final glow = _glowFor(type);

    // Glow
    canvas.drawCircle(center, r + 6,
        Paint()
          ..color = glow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Fill
    canvas.drawCircle(center, r, Paint()..color = color);

    // Inner accent ring
    canvas.drawCircle(
        center,
        r - 4,
        Paint()
          ..color = const Color(0x30FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Symbol
    _symbolPainter.paint(
      canvas,
      Offset(r - _symbolPainter.width / 2, r - _symbolPainter.height / 2),
    );
  }

  static String _symbolFor(PowerUpType t) => switch (t) {
        PowerUpType.shield => 'S',
        PowerUpType.slowMotion => 'T',
        PowerUpType.magnet => 'M',
        PowerUpType.doubleScore => '2x',
      };

  static Color _colorFor(PowerUpType t) => switch (t) {
        PowerUpType.shield => const Color(0xFF42A5F5),
        PowerUpType.slowMotion => const Color(0xFF26C6DA),
        PowerUpType.magnet => const Color(0xFFFF7043),
        PowerUpType.doubleScore => const Color(0xFFFFEE58),
      };

  static Color _glowFor(PowerUpType t) => switch (t) {
        PowerUpType.shield => const Color(0x5542A5F5),
        PowerUpType.slowMotion => const Color(0x5526C6DA),
        PowerUpType.magnet => const Color(0x55FF7043),
        PowerUpType.doubleScore => const Color(0x55FFEE58),
      };
}
