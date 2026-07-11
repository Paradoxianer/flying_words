// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/main.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/settings/persistence/memory_settings_persistence.dart';

void main() {
  testWidgets('smoke test', (tester) async {
    // Build our game and trigger a frame.
    await tester.pumpWidget(MyApp(
      settingsPersistence: MemoryOnlySettingsPersistence(),
      playerProgressPersistence: MemoryOnlyPlayerProgressPersistence(),
      adsController: null,
      gamesServicesController: null,
      inAppPurchaseController: null,
    ));

    // Verify the main menu is shown.
    expect(find.text('Flying Words'), findsOneWidget);
    expect(find.text('Spielen'), findsOneWidget);
    expect(find.text('Einstellungen'), findsOneWidget);

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

    // The first verse is offered as a lesson.
    expect(find.text('1. Korinther 12, 6'), findsOneWidget);
  });
}
