import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/currency/gold_ink.dart';
import 'package:flying_words/src/currency/persistence/memory_gold_ink_persistence.dart';
import 'package:flying_words/src/jokers/joker_inventory.dart';
import 'package:flying_words/src/jokers/joker_type.dart';
import 'package:flying_words/src/jokers/persistence/memory_joker_inventory_persistence.dart';
import 'package:flying_words/src/shop/shop_tab.dart';
import 'package:flying_words/src/style/palette.dart';
import 'package:provider/provider.dart';

import 'helpers/localized_material_app.dart';

Widget _wrap({required GoldInkController goldInk, required JokerInventoryController jokers}) {
  return MultiProvider(
    providers: [
      Provider(create: (_) => Palette()),
      ChangeNotifierProvider.value(value: goldInk),
      ChangeNotifierProvider.value(value: jokers),
    ],
    child: const LocalizedMaterialApp(home: Scaffold(body: ShopTab())),
  );
}

void main() {
  testWidgets('buying a Joker spends Goldtinte and adds it to the inventory',
      (tester) async {
    final goldInk = GoldInkController(MemoryOnlyGoldInkPersistence());
    goldInk.earn(20);
    final jokers = JokerInventoryController(MemoryOnlyJokerInventoryPersistence());

    await tester.pumpWidget(_wrap(goldInk: goldInk, jokers: jokers));

    expect(jokers.countOf(JokerType.sanduhr), 0);

    // Buy the first item (Sanduhr).
    await tester.tap(find.text('Kaufen').first);
    await tester.pump();

    expect(jokers.countOf(JokerType.sanduhr), 1);
    expect(goldInk.balance, 8); // 20 - 12

    // Flush the simulated async persistence writes so no pending timers
    // leak past the test.
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('the buy button is disabled when the balance is too low',
      (tester) async {
    final goldInk = GoldInkController(MemoryOnlyGoldInkPersistence());
    goldInk.earn(5); // Less than the 12 price.
    final jokers = JokerInventoryController(MemoryOnlyJokerInventoryPersistence());

    await tester.pumpWidget(_wrap(goldInk: goldInk, jokers: jokers));

    final buyButtons = tester.widgetList<FilledButton>(find.byType(FilledButton));
    expect(buyButtons, isNotEmpty);
    for (final button in buyButtons) {
      expect(button.onPressed, isNull);
    }

    // Flush the simulated async persistence write from earn().
    await tester.pump(const Duration(milliseconds: 700));
  });
}
