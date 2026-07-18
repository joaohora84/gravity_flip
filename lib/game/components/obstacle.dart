import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class Obstacle extends PositionComponent {
  static const double barWidth = 65.0;

  final double gapCenter;
  final double gapSize;
  double speed;
  final double playerX;
  final double _screenHeight;
  final double _groundThickness;
  final void Function()? onPassed;
  bool _scored = false;

  Obstacle({
    required double spawnX,
    required this.gapCenter,
    required this.gapSize,
    required this.speed,
    required this.playerX,
    required double screenHeight,
    required double groundThickness,
    this.onPassed,
  })  : _screenHeight = screenHeight,
        _groundThickness = groundThickness,
        super(position: Vector2(spawnX, 0));

  @override
  Future<void> onLoad() async {
    // Top bar: from ground top edge down to gap opening
    final topHeight = gapCenter - gapSize / 2 - _groundThickness;
    if (topHeight > 0) {
      await add(ObstacleBar(
        position: Vector2(0, _groundThickness),
        size: Vector2(barWidth, topHeight),
      ));
    }

    // Bottom bar: from gap bottom up to ground bottom edge
    final bottomY = gapCenter + gapSize / 2;
    final bottomHeight = _screenHeight - _groundThickness - bottomY;
    if (bottomHeight > 0) {
      await add(ObstacleBar(
        position: Vector2(0, bottomY),
        size: Vector2(barWidth, bottomHeight),
      ));
    }
  }

  @override
  void update(double dt) {
    position.x -= speed * dt;

    if (!_scored && position.x + barWidth < playerX) {
      _scored = true;
      onPassed?.call();
    }

    if (position.x + barWidth < 0) {
      removeFromParent();
    }
  }
}

class ObstacleBar extends RectangleComponent {
  static const _fillColor = Color(0xFF4527A0);
  static const _highlightColor = Color(0xFF9575CD);

  ObstacleBar({required super.position, required super.size})
      : super(paint: Paint()..color = _fillColor, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawLine(
      const Offset(2, 0),
      Offset(2, size.y),
      Paint()
        ..color = _highlightColor
        ..strokeWidth = 3,
    );
  }
}
