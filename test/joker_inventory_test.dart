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
      controller.add(JokerType.vergebung, 2);
      expect(controller.countOf(JokerType.vergebung), 2);
      expect(controller.countOf(JokerType.sanduhr), 0);

      controller.add(JokerType.vergebung);
      expect(controller.countOf(JokerType.vergebung), 3);
    });

    test('use() spends one if owned and returns true', () {
      final controller =
          JokerInventoryController(MemoryOnlyJokerInventoryPersistence());
      controller.add(JokerType.bonuszeit, 1);

      expect(controller.use(JokerType.bonuszeit), isTrue);
      expect(controller.countOf(JokerType.bonuszeit), 0);
    });

    test('use() returns false and leaves the count untouched when empty',
        () {
      final controller =
          JokerInventoryController(MemoryOnlyJokerInventoryPersistence());
      expect(controller.use(JokerType.klarheit), isFalse);
      expect(controller.countOf(JokerType.klarheit), 0);
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
        JokerType.vergebung: 1,
        JokerType.sanduhr: 0,
        JokerType.klarheit: 4,
        JokerType.bonuszeit: 0,
      });

      final controller = JokerInventoryController(store);
      await controller.getLatestFromStore();
      expect(controller.countOf(JokerType.vergebung), 1);
      expect(controller.countOf(JokerType.klarheit), 4);
    });

    test('add() ignores non-positive amounts', () {
      final controller =
          JokerInventoryController(MemoryOnlyJokerInventoryPersistence());
      controller.add(JokerType.vergebung, 0);
      controller.add(JokerType.vergebung, -3);
      expect(controller.countOf(JokerType.vergebung), 0);
    });
  });
}
