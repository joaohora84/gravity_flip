import 'package:flame/components.dart';

import '../gravity_flip_game.dart';

// The actual leaderboard display is handled by the LeaderboardScreen Flutter
// overlay (registered in main.dart). This Flame component exists only to hold
// the leaderboard state in the game's scene graph so that showMainMenu() can
// correctly clean up _activeScene when the user navigates back.
class LeaderboardScene extends Component with HasGameReference<GravityFlipGame> {
  void handleTap(Vector2 pos) {
    // Navigation is handled by the Flutter overlay's BACK button.
  }
}
