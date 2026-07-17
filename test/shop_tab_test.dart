import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/ads/ads_controller.dart';
import 'package:flying_words/src/ads/persistence/memory_rewarded_ad_limit_persistence.dart';
import 'package:flying_words/src/ads/rewarded_ad_limit_controller.dart';
import 'package:flying_words/src/currency/gold_ink.dart';
import 'package:flying_words/src/currency/persistence/memory_gold_ink_persistence.dart';
import 'package:flying_words/src/jokers/joker_inventory.dart';
import 'package:flying_words/src/jokers/joker_type.dart';
import 'package:flying_words/src/jokers/persistence/memory_joker_inventory_persistence.dart';
import 'package:flying_words/src/shop/shop_tab.dart';
import 'package:flying_words/src/style/palette.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'helpers/localized_material_app.dart';

Widget _wrap({
  required GoldInkController goldInk,
  required JokerInventoryController jokers,
  AdsController? ads,
}) {
  return MultiProvider(
    providers: [
      Provider(create: (_) => Palette()),
      ChangeNotifierProvider.value(value: goldInk),
      ChangeNotifierProvider.value(value: jokers),
      // No ads wired up by default (mirrors production on the web
      // platform, where AdsController is always null, #17) - the "watch
      // an ad" buttons must stay hidden rather than crash on a missing
      // provider.
      Provider<AdsController?>.value(value: ads),
      ChangeNotifierProvider(
        create: (_) =>
            RewardedAdLimitController(MemoryOnlyRewardedAdLimitPersistence()),
      ),
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

  testWidgets(
      'the rewarded-ad options stay hidden when no AdsController is '
      'available (#54 Phase D addendum, e.g. on the web build)',
      (tester) async {
    final goldInk = GoldInkController(MemoryOnlyGoldInkPersistence());
    final jokers = JokerInventoryController(MemoryOnlyJokerInventoryPersistence());

    await tester.pumpWidget(_wrap(goldInk: goldInk, jokers: jokers));

    expect(find.text('Werbung ansehen'), findsNothing);
    expect(find.text('Goldtinte verdienen'), findsNothing);
  });

  testWidgets(
      'the "watch an ad" button for a Joker is styled like "Kaufen" '
      '(#121: it used to be a plain text link, easy to miss as a button)',
      (tester) async {
    final goldInk = GoldInkController(MemoryOnlyGoldInkPersistence());
    final jokers = JokerInventoryController(MemoryOnlyJokerInventoryPersistence());

    await tester.pumpWidget(_wrap(
      goldInk: goldInk,
      jokers: jokers,
      ads: AdsController(MobileAds.instance),
    ));

    // Both "Kaufen" and "Werbung ansehen" render as FilledButtons now -
    // previously the per-Joker "Werbung ansehen" was a bare TextButton, so
    // this would have failed by finding fewer FilledButtons than expected.
    // One per Joker type, plus the "Goldtinte verdienen" card's own button
    // (same label, always was a FilledButton).
    expect(find.widgetWithText(FilledButton, 'Werbung ansehen'),
        findsNWidgets(5));
    expect(find.byType(TextButton), findsNothing);
  });
}
