import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/ads/persistence/memory_rewarded_ad_limit_persistence.dart';
import 'package:flying_words/src/ads/rewarded_ad_limit_controller.dart';

void main() {
  group('RewardedAdLimitController', () {
    test('starts with the full daily allowance in both categories', () {
      final controller =
          RewardedAdLimitController(MemoryOnlyRewardedAdLimitPersistence());

      expect(controller.jokerAdsWatchedToday(), 0);
      expect(controller.goldInkAdsWatchedToday(), 0);
      expect(controller.canWatchJokerAd(), isTrue);
      expect(controller.canWatchGoldInkAd(), isTrue);
    });

    test('recordJokerAdWatched() increments only the Joker count', () async {
      final controller =
          RewardedAdLimitController(MemoryOnlyRewardedAdLimitPersistence());
      final now = DateTime(2026, 7, 20);

      await controller.recordJokerAdWatched(now: now);
      await controller.recordJokerAdWatched(now: now);

      expect(controller.jokerAdsWatchedToday(now: now), 2);
      expect(controller.goldInkAdsWatchedToday(now: now), 0);
    });

    test('recordGoldInkAdWatched() increments only the Goldtinte count',
        () async {
      final controller =
          RewardedAdLimitController(MemoryOnlyRewardedAdLimitPersistence());
      final now = DateTime(2026, 7, 20);

      await controller.recordGoldInkAdWatched(now: now);

      expect(controller.goldInkAdsWatchedToday(now: now), 1);
      expect(controller.jokerAdsWatchedToday(now: now), 0);
    });

    test('blocks watching once the daily limit is reached', () async {
      final controller =
          RewardedAdLimitController(MemoryOnlyRewardedAdLimitPersistence());
      final now = DateTime(2026, 7, 20);

      for (var i = 0; i < rewardedAdDailyLimit; i++) {
        expect(controller.canWatchJokerAd(now: now), isTrue);
        await controller.recordJokerAdWatched(now: now);
      }

      expect(controller.jokerAdsWatchedToday(now: now), rewardedAdDailyLimit);
      expect(controller.canWatchJokerAd(now: now), isFalse);
      // The other category is untouched by the Joker limit.
      expect(controller.canWatchGoldInkAd(now: now), isTrue);
    });

    test('resets both counts on a new day', () async {
      final controller =
          RewardedAdLimitController(MemoryOnlyRewardedAdLimitPersistence());
      await controller.recordJokerAdWatched(now: DateTime(2026, 7, 20));
      await controller.recordGoldInkAdWatched(now: DateTime(2026, 7, 20));

      final nextDay = DateTime(2026, 7, 21);
      expect(controller.jokerAdsWatchedToday(now: nextDay), 0);
      expect(controller.goldInkAdsWatchedToday(now: nextDay), 0);
      expect(controller.canWatchJokerAd(now: nextDay), isTrue);
      expect(controller.canWatchGoldInkAd(now: nextDay), isTrue);
    });

    test('getLatestFromStore loads previously persisted counts', () async {
      final store = MemoryOnlyRewardedAdLimitPersistence();
      final seed = RewardedAdLimitController(store);
      await seed.recordJokerAdWatched(now: DateTime(2026, 7, 20));

      final reloaded = RewardedAdLimitController(store);
      await reloaded.getLatestFromStore();

      expect(reloaded.jokerAdsWatchedToday(now: DateTime(2026, 7, 20)), 1);
    });

    test('concurrent calls only load from the store once', () async {
      final store = MemoryOnlyRewardedAdLimitPersistence();
      final controller = RewardedAdLimitController(store);

      final futures = [
        controller.getLatestFromStore(),
        controller.recordJokerAdWatched(now: DateTime(2026, 7, 20)),
      ];
      await Future.wait(futures);

      expect(controller.jokerAdsWatchedToday(now: DateTime(2026, 7, 20)), 1);
    });
  });
}
