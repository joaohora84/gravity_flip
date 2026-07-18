import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../gravity_flip_game.dart';

class Ground extends Component with HasGameReference<GravityFlipGame> {
  static const double thickness = 72.0;

  @override
  Future<void> onLoad() async {
    final w = game.size.x;
    final h = game.size.y;

    await add(GroundBoundary(
      position: Vector2.zero(),
      size: Vector2(w, thickness),
      isTop: true,
    ));
    await add(GroundBoundary(
      position: Vector2(0, h - thickness),
      size: Vector2(w, thickness),
      isTop: false,
    ));
  }
}

class GroundBoundary extends RectangleComponent {
  static const _edgeColor = Color(0xFF9C8FFF);
  static const _fillColor = Color(0xFF4B3FA0);

  final bool isTop;

  GroundBoundary({
    required super.position,
    required super.size,
    required this.isTop,
  }) : super(paint: Paint()..color = _fillColor, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Highlight the inner edge (facing the play area)
    final edgeY = isTop ? size.y - 2 : 2.0;
    canvas.drawLine(
      Offset(0, edgeY),
      Offset(size.x, edgeY),
      Paint()
        ..color = _edgeColor
        ..strokeWidth = 3,
    );
  }
}
