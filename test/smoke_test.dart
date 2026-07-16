// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/main.dart';
import 'package:flying_words/src/level_selection/levels.dart';
import 'package:flying_words/src/currency/persistence/memory_gold_ink_persistence.dart';
import 'package:flying_words/src/challenges/persistence/memory_challenges_persistence.dart';
import 'package:flying_words/src/legal/persistence/memory_consent_persistence.dart';
import 'package:flying_words/src/jokers/persistence/memory_joker_inventory_persistence.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/settings/persistence/memory_settings_persistence.dart';
import 'package:flying_words/src/verses/bolls_bible_api_client.dart';
import 'package:flying_words/src/verses/custom_verses_controller.dart';
import 'package:flying_words/src/verses/persistence/memory_custom_verses_persistence.dart';

void main() {
  testWidgets('smoke test', (tester) async {
    // The curated verses are normally loaded before runApp.
    await loadCuratedVerses();

    // Build our game and trigger a frame.
    await tester.pumpWidget(MyApp(
      // Explicit language so this test doesn't depend on the test
      // runner's platform locale (#2).
      settingsPersistence: MemoryOnlySettingsPersistence()
        ..languageCode = 'de',
      playerProgressPersistence: MemoryOnlyPlayerProgressPersistence(),
      goldInkPersistence: MemoryOnlyGoldInkPersistence(),
      jokerInventoryPersistence: MemoryOnlyJokerInventoryPersistence(),
      challengesPersistence: MemoryOnlyChallengesPersistence(),
      consentPersistence: MemoryOnlyConsentPersistence(),
      adsController: null,
      gamesServicesController: null,
      inAppPurchaseController: null,
      customVersesController: CustomVersesController(
        store: MemoryCustomVersesPersistence(),
        api: BollsBibleApiClient(),
      ),
    ));

    // Verify the main menu is shown.
    expect(find.text('Flying Words'), findsOneWidget);
    expect(find.text('Spielen'), findsOneWidget);
    expect(find.text('Einstellungen'), findsOneWidget);

    // Dismiss the first-start privacy notice (#111) before interacting
    // with anything else - it shows after the simulated persistence read.
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Datenschutzhinweis'), findsOneWidget);
    await tester.tap(find.text('Verstanden'));
    await tester.pumpAndSettle();

    // Go to the settings.
    await tester.tap(find.text('Einstellungen'));
    await tester.pumpAndSettle();
    expect(find.text('Musik'), findsOneWidget);

    // Go back to the main menu.
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();

    // Go to the level selection.
    await tester.tap(find.text('Spielen'));
    await tester.pumpAndSettle();
    expect(find.text('Wähle deine Herausforderung'), findsOneWidget);

    // The first verse is offered as a lesson; each card is tall enough
    // now (Joker picker row, #53) that the second one needs a scroll.
    await tester.dragUntilVisible(
      find.text('1. Korinther 6, 12'),
      find.byType(ListView),
      const Offset(0, -100),
    );
    expect(find.text('1. Korinther 6, 12'), findsOneWidget);
  });
}
