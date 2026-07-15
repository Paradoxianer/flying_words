// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/main.dart';
import 'package:flying_words/src/level_selection/levels.dart';
import 'package:flying_words/src/currency/persistence/memory_gold_ink_persistence.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/settings/persistence/memory_settings_persistence.dart';
import 'package:flying_words/src/verses/bolls_bible_api_client.dart';
import 'package:flying_words/src/verses/custom_verses_controller.dart';
import 'package:flying_words/src/verses/persistence/memory_custom_verses_persistence.dart';

void main() {
  testWidgets('the help screen explains the rules and can be reached and left',
      (tester) async {
    // A tall surface so every help section is laid out, not just the
    // ones visible in a default-sized viewport.
    tester.view.physicalSize = const Size(800, 4000);
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
      adsController: null,
      gamesServicesController: null,
      inAppPurchaseController: null,
      customVersesController: CustomVersesController(
        store: MemoryCustomVersesPersistence(),
        api: BollsBibleApiClient(),
      ),
    ));

    // From the main menu, open the help screen.
    await tester.tap(find.text('Hilfe'));
    await tester.pumpAndSettle();

    expect(find.text('Hilfe'), findsOneWidget);
    expect(find.text('Die Siegel I, II, III'), findsOneWidget);
    expect(find.text('Das Auge — blind spielen'), findsOneWidget);
    expect(find.text('Eigene Verse'), findsOneWidget);

    // And back to the main menu again.
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('Spielen'), findsOneWidget);
  });
}
