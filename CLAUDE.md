# Gravity Flip — Project Instructions

## Project Overview
Gravity Flip is a hypercasual 2D mobile game built with Flutter + Flame Engine.
The player controls a character that flips gravity with a single tap,
navigating through rhythmic and increasingly difficult obstacles.
Inspired by Flappy Bird mechanics but with inverted gravity and power-ups.

Platform: Android + iOS
Genre: Hypercasual / Endless runner
Monetization: Rewarded Ads + Leaderboard engagement
Target: Global, all ages

---

## Core Concept
- Single tap mechanic: tap flips gravity (character goes up or down)
- Obstacles appear rhythmically, speed increases over time
- Power-ups appear randomly to help the player survive longer
- Game ends when player hits an obstacle
- Score based on distance traveled / obstacles passed
- Rewarded ad: player can continue once from where they died
- Global leaderboard via Firebase

---

## Tech Stack
- Flutter + Flame Engine (game loop, physics, rendering)
- Firebase Auth (anonymous auth for leaderboard)
- Cloud Firestore (global leaderboard storage)
- Firebase Analytics + Crashlytics
- Google AdMob (rewarded ads + interstitial between runs)
- flutter_localizations + intl (PT-BR + EN at launch)
- flame_audio (sound effects + background music)
- shared_preferences (local best score storage)

## pubspec.yaml dependencies

  dependencies:
    flutter:
      sdk: flutter
    flame: ^1.18.0
    flame_audio: ^2.1.1
    firebase_core: ^3.0.0
    firebase_analytics: ^11.0.0
    firebase_crashlytics: ^4.0.0
    cloud_firestore: ^5.0.0
    firebase_auth: ^5.0.0
    google_mobile_ads: ^5.1.0
    shared_preferences: ^2.2.0
    flutter_localizations:
      sdk: flutter
    intl: ^0.19.0

---

## Commands

    flutter pub get              # install dependencies
    flutter analyze              # static analysis — must be clean before any change is done
    flutter test                 # run all tests
    flutter test test/foo_test.dart              # run a single test file
    flutter test --plain-name "some test name"   # run a single test by name
    flutter gen-l10n             # regenerate lib/l10n/app_localizations.dart after editing the .arb files
    flutter devices              # list connected devices/emulators
    flutter run -d <device-id>   # run on a device (see "Firebase is wired eagerly" below before picking web/macOS)

## Architecture Notes

Things that aren't obvious from the file layout and require reading multiple files to piece together:

- **`GravityFlipGame` (`lib/game/gravity_flip_game.dart`) is the app's state machine.** It's a `FlameGame` holding a `GameState` enum (`menu | playing | waitingContinue | gameOver | leaderboard`) and swaps a single `_activeScene` component in and out (`MainMenu`, `GameplayScene`, `GameOverScene`, `LeaderboardScene`). All top-level transitions (`startNewGame`, `showMainMenu`, `showLeaderboard`, `onGameOver`, `_showGameOverScene`, `_continueGame`) live in this one file — start here to trace game flow. Input is routed centrally too: `onTapDown` switches on `gameState` and forwards to whichever scene is active.

- **Freezing gameplay requires overriding `updateTree`, not `update`.** In Flame, `Component.update()` is not what propagates to children — `updateTree()` calls `update()` and then unconditionally walks children regardless of what `update()` did. `GameplayScene` freezes its whole subtree (obstacles, spawners, power-ups, score) on death/continue by overriding `updateTree()` and short-circuiting when `_frozen`. Any new child system added under `GameplayScene` is paused automatically for free — no extra wiring needed, as long as it's a descendant in that component tree.

- **Two Flame asset caches, two different default prefixes.** `Images` defaults to `assets/images/`, so `GravityFlipGame.onLoad()` overrides it (`images.prefix = 'assets/sprites/'`) to match this project's folder. `flame_audio`'s `AudioCache` already defaults to `assets/audio/`, so `AudioSystem` needs no override. When loading a new sprite or sound, pass the bare filename only (`Sprite.load('foo.png')`, `AudioSystem.playSfx(...)`/`FlameAudio.play('foo.wav')`) — never the folder prefix.

- **Firebase is wired eagerly, which blocks web/macOS runs and `flutter test`.** `GravityFlipGame` constructs `LeaderboardService` as a field initializer, and `LeaderboardService`'s own constructor touches `FirebaseAuth.instance` immediately — before `onLoad()`, before any platform check. There is no `firebase_options.dart` and no web Firebase config, so `flutter run -d chrome`, `flutter run -d macos`, and `flutter test` (including the default `test/widget_test.dart`) all currently crash on boot with `[core/no-app] No Firebase App '[DEFAULT]' has been created`. The app only runs end-to-end on Android/iOS, where `google-services.json` / `GoogleService-Info.plist` are present. To test a component in isolation, don't instantiate `GravityFlipGame` — drive the component directly against a bare `FlameGame` (and `Images`/`Sprite.load` for asset-loading checks), bypassing the game class and its Firebase-coupled fields entirely.

- **`AdManager.adsEnabled` is hardcoded to `false`** (`lib/monetization/ad_manager.dart`), and both rewarded/interstitial ad unit IDs are Google's public test IDs. Flip that flag and swap in real AdMob unit IDs before any release build.

- **Difficulty is driven by score milestones, not elapsed time.** `DifficultySystem` (`game/systems/difficulty_system.dart`) is a pure class with no Flame/game imports; `GameplayScene._handleObstaclePassed()` calls it on every obstacle pass. Crossing a milestone (`[10, 25, 50, 100, 200]`) bumps speed, shrinks the gap, and shortens the spawn interval, writing the results back into `GravityFlipGame.currentSpeed` / `currentGapSize` / `currentSpawnInterval` — those three fields are the single source of truth that `ObstacleSpawner` and `Obstacle` read from every frame.

---

## Project Structure

  lib/
    main.dart
    game/
      gravity_flip_game.dart
      components/
        player.dart
        obstacle.dart
        power_up.dart
        background.dart
        ground.dart
      systems/
        gravity_system.dart
        obstacle_spawner.dart
        power_up_spawner.dart
        score_system.dart
        difficulty_system.dart
        audio_system.dart
      scenes/
        main_menu.dart
        gameplay_scene.dart
        game_over_scene.dart
        leaderboard_scene.dart
    monetization/
      ad_manager.dart
    leaderboard/
      leaderboard_service.dart
      leaderboard_screen.dart
    analytics/
      analytics_service.dart
    l10n/
      app_pt.arb
      app_en.arb
    ui/
      hud.dart
      score_display.dart
      best_score_display.dart
  assets/
    sprites/
    audio/
    fonts/

---

## Game Mechanics

### Core Loop
- Character starts moving horizontally automatically
- Tap anywhere on screen: gravity flips instantly
- No tap: gravity pulls character down
- Character must pass between obstacles (top and bottom gaps)
- Obstacles: vertical barrier pairs with a gap to pass through
- Gap position varies per obstacle (random within safe range)

### Difficulty Progression
- Speed increases gradually over time
- Gap size reduces as score increases
- Obstacle frequency increases at score milestones
- Milestones: 10, 25, 50, 100, 200 obstacles passed

### Power-ups (appear randomly between obstacles)
- Shield: absorbs one obstacle hit
- Slow Motion: reduces game speed for 3 seconds
- Magnet: attracts coins/points automatically
- Double Score: doubles points for 5 seconds

### Scoring
- +1 point per obstacle successfully passed
- Bonus multiplier from power-ups
- Local best score saved with shared_preferences
- Online score submitted to Firebase Firestore leaderboard

---

## Leaderboard
- Anonymous Firebase Auth on first launch
- Player sets a display name on first score submission
- Top 100 global scores stored in Firestore
- Leaderboard screen shows: rank, name, score
- Player's personal best always highlighted
- Real-time updates via Firestore snapshots

---

## Monetization

### Rewarded Ads
- Trigger: player dies → "Continue?" screen appears
- Player watches rewarded ad → continues from exact death point
- Limited to 1 continue per run (no infinite continues)
- If player declines: goes to game over screen

### Interstitial Ads
- Shown on game over screen after 3rd run or more
- Never shown on first or second run (UX protection)
- Cooldown: minimum 3 minutes between interstitials

### Future IAP (phase 2)
- Remove ads (permanent)
- Character skins
- Trail effects

---

## Scenes Flow

  Main Menu
    → Tap to Play → Gameplay Scene
    → Leaderboard button → Leaderboard Scene

  Gameplay Scene
    → Player dies → Continue? screen
      → Watch ad → Resume gameplay
      → Decline → Game Over Scene

  Game Over Scene
    → Show score + best score
    → Submit to leaderboard (if top score)
    → Play Again → Gameplay Scene
    → Main Menu → Main Menu

---

## Visual Style
- Minimalist flat design, bold colors
- Character: simple geometric shape (square or capsule)
- Obstacles: clean vertical bars, color coded by difficulty
- Background: parallax scrolling, gradient sky
- Power-ups: distinct icons with glow effect
- No realistic violence — suitable for all ages

---

## Localization
- Launch: pt_BR + en
- Auto-detect device locale, fallback to English
- All UI text via .arb files — never hardcoded strings
- Leaderboard player names: no restriction on language

---

## Analytics Events (Firebase)
- game_start
- game_over (with score value)
- obstacle_passed (milestone only: 10, 25, 50, 100)
- power_up_collected (with type)
- rewarded_ad_watched
- rewarded_ad_declined
- leaderboard_viewed
- leaderboard_score_submitted

---

## Development Rules
1. Follow the project structure above for every new file
2. Flame components must extend correct Flame Engine classes
3. All UI text via localization system — never hardcoded strings
4. AdMob logic isolated in /monetization module
5. Leaderboard logic isolated in /leaderboard module
6. Code comments in English
7. Variables and methods named in English
8. One system at a time — incremental implementation
9. Keep game logic and UI logic clearly separated

---

## Before Every Implementation
1. Confirm with the user what will be implemented
2. Wait for explicit user approval before writing any code
3. If a decision impacts another part of the game, flag it first
4. If multiple approaches exist, present the options before proceeding
5. Never implement more than what was approved in that session

---

## Session Protocol
At the start of each session say:
"Gravity Flip project loaded. Last session: [ask user].
What do we implement today?"