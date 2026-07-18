import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../analytics/analytics_service.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../leaderboard/leaderboard_service.dart';
import '../monetization/ad_manager.dart';
import 'components/background.dart';
import 'components/ground.dart';
import 'components/power_up.dart';
import 'scenes/game_over_scene.dart';
import 'scenes/gameplay_scene.dart';
import 'scenes/leaderboard_scene.dart';
import 'scenes/main_menu.dart';
import 'systems/audio_system.dart';

enum GameState { menu, playing, waitingContinue, gameOver, leaderboard }

class GravityFlipGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  GameState gameState = GameState.menu;
  double currentSpeed = 250.0;
  double currentGapSize = 220.0;
  double currentSpawnInterval = 2.2;

  // Power-up effect state
  bool hasShield = false;
  bool isDoubleScore = false;
  bool isSlowMotion = false;
  double _slowMotionTimer = 0;
  double _doubleScoreTimer = 0;
  double _speedBeforeSlowMo = 250.0;

  static const _slowMotionDuration = 3.0;
  static const _doubleScoreDuration = 5.0;

  AppLocalizations? strings;

  final leaderboardService = LeaderboardService();
  int pendingLeaderboardScore = 0;

  final adManager = AdManager();
  final analyticsService = AnalyticsService();

  GameplayScene? _gameplayScene;
  Component? _activeScene;
  Component? _continueOverlay;
  Rect? _noThanksRect;

  @override
  Color backgroundColor() => const Color(0xFF0D0D1A);

  @override
  Future<void> onLoad() async {
    images.prefix = 'assets/sprites/';
    await AudioSystem.preload();
    await leaderboardService.initialize();
    await adManager.initialize();
    await add(Background());
    await add(Ground());
    await _showMainMenu();
  }

  // ── Scene transitions ──────────────────────────────────────────────────────

  Future<void> _showMainMenu() async {
    overlays.remove(LeaderboardScreen.id);
    overlays.remove(NameEntryOverlay.id);
    _activeScene?.removeFromParent();
    _continueOverlay?.removeFromParent();
    _continueOverlay = null;
    _noThanksRect = null;
    _gameplayScene = null;
    gameState = GameState.menu;

    final menu = MainMenu();
    _activeScene = menu;
    await add(menu);
  }

  Future<void> startNewGame() async {
    adManager.incrementRunCount();
    analyticsService.logGameStart();
    overlays.remove(NameEntryOverlay.id);
    _resetEffects();
    _activeScene?.removeFromParent();
    _continueOverlay?.removeFromParent();
    _continueOverlay = null;
    _noThanksRect = null;
    currentSpeed = 250.0;
    currentGapSize = 220.0;
    currentSpawnInterval = 2.2;
    gameState = GameState.playing;

    final scene = GameplayScene();
    _gameplayScene = scene;
    _activeScene = scene;
    await add(scene);
  }

  Future<void> showMainMenu() => _showMainMenu();

  Future<void> showLeaderboard() async {
    analyticsService.logLeaderboardViewed();
    _activeScene?.removeFromParent();
    gameState = GameState.leaderboard;

    final scene = LeaderboardScene();
    _activeScene = scene;
    await add(scene);
    overlays.add(LeaderboardScreen.id);
  }

  void triggerNameEntry(int score) {
    pendingLeaderboardScore = score;
    overlays.add(NameEntryOverlay.id);
  }

  void hideNameEntry() {
    overlays.remove(NameEntryOverlay.id);
  }

  void declineContinue() {
    final score = _gameplayScene?.currentScore ?? 0;
    final best = _gameplayScene?.bestScore ?? 0;
    final isNew = _gameplayScene?.isNewBest ?? false;
    _showGameOverScene(score: score, best: best, isNewBest: isNew);
  }

  // ── Game logic ─────────────────────────────────────────────────────────────

  void applyPowerUp(PowerUpType type) {
    analyticsService.logPowerUpCollected(type.name);
    AudioSystem.playSfx(Sfx.powerUp);
    switch (type) {
      case PowerUpType.shield:
        hasShield = true;
      case PowerUpType.slowMotion:
        _speedBeforeSlowMo = currentSpeed;
        currentSpeed *= 0.5;
        isSlowMotion = true;
        _slowMotionTimer = _slowMotionDuration;
      case PowerUpType.magnet:
        _gameplayScene?.grantScore(5);
      case PowerUpType.doubleScore:
        isDoubleScore = true;
        _doubleScoreTimer = _doubleScoreDuration;
    }
  }

  void consumeShield() => hasShield = false;

  void updateBaseSpeed(double newSpeed) {
    if (isSlowMotion) {
      _speedBeforeSlowMo = newSpeed;
    } else {
      currentSpeed = newSpeed;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState != GameState.playing) return;

    if (isSlowMotion) {
      _slowMotionTimer -= dt;
      if (_slowMotionTimer <= 0) {
        isSlowMotion = false;
        currentSpeed = _speedBeforeSlowMo;
      }
    }

    if (isDoubleScore) {
      _doubleScoreTimer -= dt;
      if (_doubleScoreTimer <= 0) {
        isDoubleScore = false;
      }
    }
  }

  void onGameOver() {
    if (gameState == GameState.waitingContinue ||
        gameState == GameState.gameOver) {
      return;
    }
    gameState = GameState.waitingContinue;
    _gameplayScene?.freeze();
    _showContinueScreen();
  }

  void _showContinueScreen() {
    final cx = size.x / 2;
    final cy = size.y / 2;

    final overlay = PositionComponent();

    // Semi-transparent dim panel
    overlay.add(RectangleComponent(
      position: Vector2(cx - 150, cy - 100),
      size: Vector2(300, 200),
      paint: Paint()..color = const Color(0xCC0A0A20),
    ));

    overlay.add(TextComponent(
      text: strings?.continueQuestion ?? 'CONTINUE?',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, cy - 55),
    ));

    // Phase 8: replace with rewarded-ad button
    overlay.add(TextComponent(
      text: strings?.tapToContinue ?? 'TAP SCREEN TO CONTINUE',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, cy - 15),
    ));

    const ntW = 180.0;
    const ntH = 42.0;
    final ntY = cy + 50;
    _noThanksRect = Rect.fromCenter(
      center: Offset(cx, ntY),
      width: ntW,
      height: ntH,
    );
    overlay.add(RectangleComponent(
      position: Vector2(cx - ntW / 2, ntY - ntH / 2),
      size: Vector2(ntW, ntH),
      paint: Paint()..color = const Color(0xFF1A1A30),
    ));
    overlay.add(TextComponent(
      text: strings?.noThanks ?? 'NO THANKS',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF777799),
          fontSize: 12,
          letterSpacing: 2,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, ntY),
    ));

    _continueOverlay = overlay;
    add(overlay);
  }

  void _showGameOverScene({
    required int score,
    required int best,
    required bool isNewBest,
  }) {
    _continueOverlay?.removeFromParent();
    _continueOverlay = null;
    _noThanksRect = null;
    _activeScene?.removeFromParent();
    _gameplayScene = null;
    gameState = GameState.gameOver;

    final scene = GameOverScene(
      score: score,
      bestScore: best,
      isNewBest: isNewBest,
    );
    _activeScene = scene;
    add(scene);

    analyticsService.logGameOver(score);
    adManager.showInterstitialIfReady();
  }

  void _continueGame() {
    analyticsService.logRewardedAdWatched();
    _continueOverlay?.removeFromParent();
    _continueOverlay = null;
    _noThanksRect = null;
    gameState = GameState.playing;
    _gameplayScene?.unfreeze();
    adManager.loadRewardedAd();
  }

  void _resetEffects() {
    hasShield = false;
    isDoubleScore = false;
    isSlowMotion = false;
    _slowMotionTimer = 0;
    _doubleScoreTimer = 0;
    _speedBeforeSlowMo = 250.0;
  }

  // ── Input routing ──────────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    switch (gameState) {
      case GameState.menu:
        (_activeScene as MainMenu?)?.handleTap(event.localPosition);
      case GameState.playing:
        _gameplayScene?.player?.flip();
      case GameState.waitingContinue:
        if (_noThanksRect?.contains(event.localPosition.toOffset()) == true) {
          analyticsService.logRewardedAdDeclined();
          declineContinue();
        } else {
          adManager.showRewardedAd(
            onRewarded: _continueGame,
            onFailed: declineContinue,
          );
        }
      case GameState.gameOver:
        (_activeScene as GameOverScene?)?.handleTap(event.localPosition);
      case GameState.leaderboard:
        (_activeScene as LeaderboardScene?)?.handleTap(event.localPosition);
    }
  }
}
