import 'dart:math';

import 'package:flame/components.dart';

import '../components/ground.dart';
import '../components/power_up.dart';
import '../gravity_flip_game.dart';

class PowerUpSpawner extends Component
    with HasGameReference<GravityFlipGame> {
  static const double _minInterval = 5.0;
  static const double _maxInterval = 9.0;

  final _random = Random();
  double _elapsed = 0;
  late double _nextInterval;

  @override
  void onMount() {
    super.onMount();
    _nextInterval = _randomInterval();
  }

  double _randomInterval() =>
      _minInterval + _random.nextDouble() * (_maxInterval - _minInterval);

  @override
  void update(double dt) {
    _elapsed += dt;
    if (_elapsed >= _nextInterval) {
      _elapsed = 0;
      _nextInterval = _randomInterval();
      _spawnPowerUp();
    }
  }

  void _spawnPowerUp() {
    const gt = Ground.thickness;
    const padding = 50.0;
    final h = game.size.y;

    final spawnY = gt + padding + _random.nextDouble() * (h - gt * 2 - padding * 2);
    final type = PowerUpType.values[_random.nextInt(PowerUpType.values.length)];

    parent!.add(PowerUp(
      type: type,
      spawnX: game.size.x + 24,
      spawnY: spawnY,
    ));
  }
}
