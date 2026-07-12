// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/main.dart';
import 'package:flying_words/src/level_selection/levels.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/settings/persistence/memory_settings_persistence.dart';
import 'package:flying_words/src/settings/settings.dart';
import 'package:flying_words/src/verses/bolls_bible_api_client.dart';
import 'package:flying_words/src/verses/custom_verses_controller.dart';
import 'package:flying_words/src/verses/persistence/memory_custom_verses_persistence.dart';

void main() {
  group('resolveInitialLocale', () {
    test('an explicit stored choice always wins', () {
      expect(
          resolveInitialLocale('en', deviceLocale: const Locale('de'))
              .languageCode,
          'en');
    });

    test('falls back to the device locale when nothing is stored', () {
      expect(
          resolveInitialLocale(null, deviceLocale: const Locale('en'))
              .languageCode,
          'en');
    });

    test('falls back to German for an unsupported device locale', () {
      expect(
          resolveInitialLocale(null, deviceLocale: const Locale('fr'))
              .languageCode,
          'de');
    });
  });

  testWidgets(
      'with no explicit choice and a German device locale, starts German '
      'and can switch to English from settings', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('de');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await loadCuratedVerses();
    final settingsPersistence = MemoryOnlySettingsPersistence();

    await tester.pumpWidget(MyApp(
      settingsPersistence: settingsPersistence,
      playerProgressPersistence: MemoryOnlyPlayerProgressPersistence(),
      adsController: null,
      gamesServicesController: null,
      inAppPurchaseController: null,
      customVersesController: CustomVersesController(
        store: MemoryCustomVersesPersistence(),
        api: BollsBibleApiClient(),
      ),
    ));
    await tester.pump();

    expect(find.text('Spielen'), findsOneWidget);

    // Switch to English from the settings screen.
    await tester.tap(find.text('Einstellungen'));
    await tester.pumpAndSettle();
    expect(find.text('Sprache'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);

    await tester.tap(find.text('Sprache'));
    await tester.pumpAndSettle();
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // The choice is persisted.
    expect(settingsPersistence.languageCode, 'en');

    // Leaving settings shows the rest of the app in English too.
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Play'), findsOneWidget);
  });
}
