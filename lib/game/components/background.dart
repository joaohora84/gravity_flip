import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../gravity_flip_game.dart';

class Background extends PositionComponent
    with HasGameReference<GravityFlipGame> {
  final _random = Random(42);
  late Paint _skyPaint;
  late List<_ScrollLayer> _layers;

  @override
  Future<void> onLoad() async {
    size = game.size;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D0D2B),
          Color(0xFF16103A),
          Color(0xFF0D1B2A),
        ],
      ).createShader(rect);

    _layers = [
      _ScrollLayer(
        speed: 20,
        items: _buildDots(50, 2.0),
        color: const Color(0x55FFFFFF),
      ),
      _ScrollLayer(
        speed: 55,
        items: _buildDots(20, 3.5),
        color: const Color(0x336699FF),
      ),
    ];
  }

  List<Vector2> _buildDots(int count, double radius) {
    return List.generate(count, (_) => Vector2(
      _random.nextDouble() * size.x,
      _random.nextDouble() * size.y,
    ));
  }

  @override
  void update(double dt) {
    for (final layer in _layers) {
      layer.offset = (layer.offset + layer.speed * dt) % size.x;
    }
  }

  @override
  void render(Canvas canvas) {
    // Sky gradient
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _skyPaint);

    // Parallax dots — scrolled horizontally, wrapped at screen edge
    for (final layer in _layers) {
      final paint = Paint()..color = layer.color;
      for (final pos in layer.items) {
        final x = (pos.x - layer.offset + size.x) % size.x;
        canvas.drawCircle(Offset(x, pos.y), 2, paint);
        if (x < 4) {
          canvas.drawCircle(Offset(x + size.x, pos.y), 2, paint);
        }
      }
    }
  }
}

class _ScrollLayer {
  final double speed;
  final List<Vector2> items;
  final Color color;
  double offset = 0;

  _ScrollLayer({
    required this.speed,
    required this.items,
    required this.color,
  });
}
