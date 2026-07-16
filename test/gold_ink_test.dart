import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/currency/gold_ink.dart';
import 'package:flying_words/src/currency/persistence/memory_gold_ink_persistence.dart';
import 'package:flying_words/src/game_internals/lesson.dart';

void main() {
  group('goldInkForRun', () {
    test('a non-flawless run earns nothing on seal I/II (#54)', () {
      // 2 errors on Seal I/II is worth 2 stars, not the max 3 - not flawless.
      expect(goldInkForRun(Difficulty.slow, 2), 0);
      expect(goldInkForRun(Difficulty.normal, 2), 0);
      // Even the blind bonus can't turn a non-flawless run into a reward.
      expect(goldInkForRun(Difficulty.slow, 2, blindBonus: true), 0);
    });

    test('a flawless (0-error) run earns the base reward', () {
      expect(goldInkForRun(Difficulty.slow, 0), 5);
      expect(goldInkForRun(Difficulty.normal, 0), 12);
    });

    test(
        'seal III always earns its reward - its only star is already a '
        'completion star', () {
      expect(goldInkForRun(Difficulty.insane, 0), 25);
      expect(goldInkForRun(Difficulty.insane, 5), 25);
    });

    test('the blind bonus adds 50% on top of a flawless run', () {
      expect(goldInkForRun(Difficulty.slow, 0, blindBonus: true), 8);
      expect(goldInkForRun(Difficulty.insane, 0, blindBonus: true), 38);
    });

    test('using a joker halves the total, applied last (#53)', () {
      // A non-flawless run stays at 0 regardless.
      expect(goldInkForRun(Difficulty.slow, 2, jokerUsed: true), 0);
      // Flawless, halved: 5 * 0.5 = 2.5 -> 3.
      expect(goldInkForRun(Difficulty.slow, 0, jokerUsed: true), 3);
      // Flawless + blind + joker: 5 * 1.5 * 0.5 = 3.75 -> 4.
      expect(
        goldInkForRun(Difficulty.slow, 0,
            blindBonus: true, jokerUsed: true),
        4,
      );
    });
  });

  group('GoldInkController', () {
    test('starts at zero and earn() adds to the balance', () {
      final controller = GoldInkController(MemoryOnlyGoldInkPersistence());
      expect(controller.balance, 0);

      controller.earn(10);
      expect(controller.balance, 10);

      controller.earn(15);
      expect(controller.balance, 25);
    });

    test('earn() persists the new balance', () async {
      final store = MemoryOnlyGoldInkPersistence();
      final controller = GoldInkController(store);
      controller.earn(20);

      // Flush the simulated async persistence write.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(await store.getBalance(), 20);
    });

    test('getLatestFromStore loads a previously persisted balance',
        () async {
      final store = MemoryOnlyGoldInkPersistence();
      await store.saveBalance(42);

      final controller = GoldInkController(store);
      await controller.getLatestFromStore();
      expect(controller.balance, 42);
    });

    test('earn() ignores non-positive amounts', () {
      final controller = GoldInkController(MemoryOnlyGoldInkPersistence());
      controller.earn(0);
      controller.earn(-5);
      expect(controller.balance, 0);
    });

    test('spend() deducts the balance and persists it when affordable',
        () async {
      final store = MemoryOnlyGoldInkPersistence();
      final controller = GoldInkController(store);
      controller.earn(20);

      expect(controller.spend(12), isTrue);
      expect(controller.balance, 8);

      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(await store.getBalance(), 8);
    });

    test('spend() fails and leaves the balance untouched when short', () {
      final controller = GoldInkController(MemoryOnlyGoldInkPersistence());
      controller.earn(10);

      expect(controller.spend(12), isFalse);
      expect(controller.balance, 10);
    });

    test('spend() ignores non-positive amounts', () {
      final controller = GoldInkController(MemoryOnlyGoldInkPersistence());
      controller.earn(10);

      expect(controller.spend(0), isFalse);
      expect(controller.spend(-5), isFalse);
      expect(controller.balance, 10);
    });
  });
}
