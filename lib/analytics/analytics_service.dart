import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final _analytics = FirebaseAnalytics.instance;

  Future<void> logGameStart() =>
      _analytics.logEvent(name: 'game_start');

  Future<void> logGameOver(int score) =>
      _analytics.logEvent(name: 'game_over', parameters: {'score': score});

  Future<void> logObstaclePassed(int milestone) =>
      _analytics.logEvent(
        name: 'obstacle_passed',
        parameters: {'milestone': milestone},
      );

  Future<void> logPowerUpCollected(String type) =>
      _analytics.logEvent(
        name: 'power_up_collected',
        parameters: {'type': type},
      );

  Future<void> logRewardedAdWatched() =>
      _analytics.logEvent(name: 'rewarded_ad_watched');

  Future<void> logRewardedAdDeclined() =>
      _analytics.logEvent(name: 'rewarded_ad_declined');

  Future<void> logLeaderboardViewed() =>
      _analytics.logEvent(name: 'leaderboard_viewed');

  Future<void> logLeaderboardScoreSubmitted(int score) =>
      _analytics.logEvent(
        name: 'leaderboard_score_submitted',
        parameters: {'score': score},
      );
}
