import 'package:flame/components.dart';

import '../../ui/hud.dart';
import '../components/player.dart';
import '../gravity_flip_game.dart';
import '../systems/audio_system.dart';
import '../systems/difficulty_system.dart';
import '../systems/obstacle_spawner.dart';
import '../systems/power_up_spawner.dart';
import '../systems/score_system.dart';

class GameplayScene extends Component with HasGameReference<GravityFlipGame> {
  Player? player;

  late final ScoreSystem _scoreSystem;
  late final Hud _hud;
  final _difficulty = DifficultySystem();
  bool _frozen = false;

  @override
  Future<void> onLoad() async {
    AudioSystem.playGameplayMusic();

    _hud = Hud();
    await add(_hud);

    _scoreSystem = ScoreSystem();
    await add(_scoreSystem);

    player = Player();
    await add(player!);

    await add(ObstacleSpawner(onObstaclePassed: _handleObstaclePassed));
    await add(PowerUpSpawner());
  }

  @override
  void updateTree(double dt) {
    if (_frozen) return;
    super.updateTree(dt);
  }

  void _handleObstaclePassed() {
    AudioSystem.playSfx(Sfx.point);
    final times = game.isDoubleScore ? 2 : 1;
    for (var i = 0; i < times; i++) {
      _scoreSystem.increment();
    }
    _hud.updateScore(_scoreSystem.currentScore);
    _hud.updateBest(_scoreSystem.bestScore);

    if (_difficulty.check(_scoreSystem.currentScore)) {
      game.updateBaseSpeed(_difficulty.speed);
      game.currentGapSize = _difficulty.gapSize;
      game.currentSpawnInterval = _difficulty.spawnInterval;
      game.analyticsService.logObstaclePassed(_scoreSystem.currentScore);
      AudioSystem.playSfx(Sfx.milestone);
    }
  }

  void grantScore(int amount) {
    _scoreSystem.incrementBy(amount);
    _hud.updateScore(_scoreSystem.currentScore);
    _hud.updateBest(_scoreSystem.bestScore);
  }

  void freeze() {
    _frozen = true;
    player?.freeze();
  }

  void unfreeze() {
    _frozen = false;
    player?.unfreeze();
  }

  int get currentScore => _scoreSystem.currentScore;
  int get bestScore => _scoreSystem.bestScore;
  bool get isNewBest => _scoreSystem.isNewBest;
}
