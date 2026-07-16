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
import 'package:flying_words/src/ads/persistence/memory_rewarded_ad_limit_persistence.dart';
import 'package:flying_words/src/jokers/persistence/memory_joker_inventory_persistence.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/settings/persistence/memory_settings_persistence.dart';
import 'package:flying_words/src/verses/bolls_bible_api_client.dart';
import 'package:flying_words/src/verses/custom_verses_controller.dart';
import 'package:flying_words/src/verses/persistence/memory_custom_verses_persistence.dart';

void main() {
  testWidgets(
      'the privacy policy is reachable from settings and covers ads, '
      'game services and the planned cloud save (#18)', (tester) async {
    // A tall surface so every section is laid out, not just the ones
    // visible in a default-sized viewport.
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await loadCuratedVerses();

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
      rewardedAdLimitPersistence: MemoryOnlyRewardedAdLimitPersistence(),
      adsController: null,
      gamesServicesController: null,
      inAppPurchaseController: null,
      customVersesController: CustomVersesController(
        store: MemoryCustomVersesPersistence(),
        api: BollsBibleApiClient(),
      ),
    ));

    // Dismiss the first-start privacy notice (#111) before interacting
    // with anything else.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Verstanden'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Einstellungen'));
    await tester.pumpAndSettle();

    // No AdsController is wired up in this test, so the "reopen consent
    // form" entry must stay hidden - it only makes sense once ads exist.
    expect(find.text('Datenschutzeinstellungen für Werbung'), findsNothing);

    await tester.tap(find.text('Datenschutz'));
    await tester.pumpAndSettle();

    expect(find.text('Datenschutz'), findsWidgets);
    expect(find.text('Werbung (Google AdMob)'), findsOneWidget);
    expect(find.text('Spielerkonto & Bestenliste'), findsOneWidget);
    expect(find.text('Geplante Cloud-Speicherung (in Vorbereitung)'),
        findsOneWidget);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('Einstellungen'), findsOneWidget);
  });
}
