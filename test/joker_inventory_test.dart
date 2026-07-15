import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/jokers/joker_inventory.dart';
import 'package:flying_words/src/jokers/joker_type.dart';
import 'package:flying_words/src/jokers/persistence/memory_joker_inventory_persistence.dart';

void main() {
  group('JokerInventoryController', () {
    test('starts at zero for every Joker type', () {
      final controller =
          JokerInventoryController(MemoryOnlyJokerInventoryPersistence());
      for (final type in JokerType.values) {
        expect(controller.countOf(type), 0);
      }
    });

    test('add() increases the count for that Joker only', () {
      final controller =
          JokerInventoryController(MemoryOnlyJokerInventoryPersistence());
      controller.add(JokerType.grace, 2);
      expect(controller.countOf(JokerType.grace), 2);
      expect(controller.countOf(JokerType.sanduhr), 0);

      controller.add(JokerType.grace);
      expect(controller.countOf(JokerType.grace), 3);
    });

    test('use() spends one if owned and returns true', () {
      final controller =
          JokerInventoryController(MemoryOnlyJokerInventoryPersistence());
      controller.add(JokerType.federkiel, 1);

      expect(controller.use(JokerType.federkiel), isTrue);
      expect(controller.countOf(JokerType.federkiel), 0);
    });

    test('use() returns false and leaves the count untouched when empty',
        () {
      final controller =
          JokerInventoryController(MemoryOnlyJokerInventoryPersistence());
      expect(controller.use(JokerType.tintenloescher), isFalse);
      expect(controller.countOf(JokerType.tintenloescher), 0);
    });

    test('add() and use() persist the new counts', () async {
      final store = MemoryOnlyJokerInventoryPersistence();
      final controller = JokerInventoryController(store);
      controller.add(JokerType.sanduhr, 2);
      controller.use(JokerType.sanduhr);

      // Flush the simulated async persistence writes.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final saved = await store.getCounts();
      expect(saved[JokerType.sanduhr], 1);
    });

    test('getLatestFromStore loads previously persisted counts', () async {
      final store = MemoryOnlyJokerInventoryPersistence();
      await store.saveCounts({
        JokerType.grace: 1,
        JokerType.sanduhr: 0,
        JokerType.tintenloescher: 4,
        JokerType.federkiel: 0,
      });

      final controller = JokerInventoryController(store);
      await controller.getLatestFromStore();
      expect(controller.countOf(JokerType.grace), 1);
      expect(controller.countOf(JokerType.tintenloescher), 4);
    });

    test('add() ignores non-positive amounts', () {
      final controller =
          JokerInventoryController(MemoryOnlyJokerInventoryPersistence());
      controller.add(JokerType.grace, 0);
      controller.add(JokerType.grace, -3);
      expect(controller.countOf(JokerType.grace), 0);
    });
  });
}
