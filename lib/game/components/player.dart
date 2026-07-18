import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../gravity_flip_game.dart';
import '../systems/audio_system.dart';
import '../systems/gravity_system.dart';
import 'ground.dart';
import 'obstacle.dart';
import 'power_up.dart';

class Player extends SpriteComponent
    with HasGameReference<GravityFlipGame>, CollisionCallbacks {
  static const double _size = 36.0;

  static const _glowColor = Color(0x3300D4FF);

  final _gravitySystem = GravitySystem();

  Player()
      : super(
          size: Vector2.all(_size),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
    position = Vector2(
      game.size.x * 0.25,
      game.size.y / 2,
    );
    await add(RectangleHitbox());
  }

  void flip() {
    _gravitySystem.flip();
    AudioSystem.playSfx(Sfx.flip);
  }

  void freeze() => _gravitySystem.freeze();

  void unfreeze() => _gravitySystem.unfreeze();

  @override
  void update(double dt) {
    position.y += _gravitySystem.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // Glow behind the body
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: size.x + 12,
        height: size.y + 12,
      ),
      Paint()
        ..color = _glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    super.render(canvas);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is GroundBoundary || other is ObstacleBar) {
      if (game.hasShield) {
        AudioSystem.playSfx(Sfx.shieldBlock);
        game.consumeShield();
      } else {
        AudioSystem.playSfx(Sfx.hit);
        game.onGameOver();
      }
    } else if (other is PowerUp) {
      game.applyPowerUp(other.type);
    }
  }
}
