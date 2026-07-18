import 'package:flame/components.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreSystem extends Component {
  static const _bestScoreKey = 'best_score';

  int currentScore = 0;
  int bestScore = 0;
  bool isNewBest = false;

  @override
  Future<void> onLoad() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt(_bestScoreKey) ?? 0;
  }

  void increment() {
    currentScore++;
    _checkBest();
  }

  void incrementBy(int amount) {
    currentScore += amount;
    _checkBest();
  }

  void _checkBest() {
    if (currentScore > bestScore) {
      bestScore = currentScore;
      isNewBest = true;
      _persist();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, bestScore);
  }
}
