import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/currency/gold_ink.dart';
import 'package:flying_words/src/currency/persistence/memory_gold_ink_persistence.dart';
import 'package:flying_words/src/game_internals/lesson.dart';

void main() {
  group('goldInkForRun', () {
    test('base reward per seal for a non-flawless run', () {
      // 2 errors on Seal I/II is worth 2 stars, not the max 3 - not flawless.
      expect(goldInkForRun(Difficulty.slow, 2), 10);
      expect(goldInkForRun(Difficulty.normal, 2), 25);
      // Seal III's only star is the "flawless" one - any completed run at
      // all earns it, so the bonus always applies there.
      expect(goldInkForRun(Difficulty.insane, 0), 90);
    });

    test('a flawless (0-error) run earns the +50% bonus', () {
      expect(goldInkForRun(Difficulty.slow, 0), 15);
      expect(goldInkForRun(Difficulty.normal, 0), 38);
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
  });
}
