import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  int _runCount = 0;
  DateTime? _lastInterstitialShown;

  static const _minRunsForInterstitial = 3;
  static const _interstitialCooldown = Duration(minutes: 3);

  // Set to true before publishing
  static const adsEnabled = false;

  // Google test IDs — replace with real AdMob IDs before publishing
  static String get _rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  static String get _interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadRewardedAd();
    loadInterstitialAd();
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  void showRewardedAd({
    required void Function() onRewarded,
    required void Function() onFailed,
  }) {
    if (!adsEnabled) {
      onFailed();
      return;
    }
    final ad = _rewardedAd;
    if (ad == null) {
      onFailed();
      return;
    }
    _rewardedAd = null;
    bool rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
        if (!rewarded) { onFailed(); }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        loadRewardedAd();
        onFailed();
      },
    );

    ad.show(onUserEarnedReward: (_, __) {
      rewarded = true;
      onRewarded();
    });
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  // ── Interstitial ──────────────────────────────────────────────────────────

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void incrementRunCount() => _runCount++;

  void showInterstitialIfReady() {
    if (!adsEnabled) return;
    if (_runCount < _minRunsForInterstitial) return;

    final last = _lastInterstitialShown;
    if (last != null &&
        DateTime.now().difference(last) < _interstitialCooldown) {
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) return;

    _interstitialAd = null;
    _lastInterstitialShown = DateTime.now();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        loadInterstitialAd();
      },
    );

    ad.show();
  }
}
