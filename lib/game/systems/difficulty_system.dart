// Pure class — no Flame or game imports. GameplayScene applies the values.
class DifficultySystem {
  static const List<int> milestones = [10, 25, 50, 100, 200];

  static const double _baseSpeed = 250.0;
  static const double _baseGapSize = 220.0;
  static const double _baseSpawnInterval = 2.2;

  static const double _speedStep = 35.0;
  static const double _gapStep = 15.0;
  static const double _intervalStep = 0.15;

  int _level = 0;

  // Returns true when the level increased (caller should apply new values).
  bool check(int score) {
    final newLevel = milestones.where((m) => score >= m).length;
    if (newLevel > _level) {
      _level = newLevel;
      return true;
    }
    return false;
  }

  double get speed => _baseSpeed + _level * _speedStep;
  double get gapSize =>
      (_baseGapSize - _level * _gapStep).clamp(100.0, _baseGapSize);
  double get spawnInterval =>
      (_baseSpawnInterval - _level * _intervalStep).clamp(0.8, _baseSpawnInterval);
}
