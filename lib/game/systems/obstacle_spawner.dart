import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../components/ground.dart';
import '../components/obstacle.dart';
import '../gravity_flip_game.dart';

class ObstacleSpawner extends Component
    with HasGameReference<GravityFlipGame> {
  final VoidCallback? onObstaclePassed;

  final _random = Random();
  double _elapsed = 0.0;

  ObstacleSpawner({this.onObstaclePassed});

  @override
  void update(double dt) {
    _elapsed += dt;
    if (_elapsed >= game.currentSpawnInterval) {
      _elapsed = 0;
      _spawnObstacle();
    }
  }

  void _spawnObstacle() {
    final h = game.size.y;
    const gt = Ground.thickness;
    final gapSize = game.currentGapSize;
    final half = gapSize / 2;

    final minCenter = gt + half;
    final maxCenter = h - gt - half;
    final gapCenter = minCenter + _random.nextDouble() * (maxCenter - minCenter);

    parent!.add(Obstacle(
      spawnX: game.size.x + Obstacle.barWidth,
      gapCenter: gapCenter,
      gapSize: gapSize,
      speed: game.currentSpeed,
      playerX: game.size.x * 0.25,
      screenHeight: h,
      groundThickness: gt,
      onPassed: onObstaclePassed,
    ));
  }
}
