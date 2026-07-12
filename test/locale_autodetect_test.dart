// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/main.dart';
import 'package:flying_words/src/level_selection/levels.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/settings/persistence/memory_settings_persistence.dart';
import 'package:flying_words/src/verses/bolls_bible_api_client.dart';
import 'package:flying_words/src/verses/custom_verses_controller.dart';
import 'package:flying_words/src/verses/persistence/memory_custom_verses_persistence.dart';

/// Kept in its own file, one [MyApp] `pumpWidget` per test: stacking more
/// than one full-`MyApp` `testWidgets` in the same file/process leaks a
/// pending timer between tests (most likely from the real, unmocked
/// `AudioController`) and hangs the next one - the same reason
/// `smoke_test.dart` and `help_screen_test.dart` each only build [MyApp]
/// once. Rebuilding via a second `pumpWidget` call in one test doesn't work
/// either: `MyApp`'s `Provider<SettingsController>` only runs its `create`
/// once, so a second `pumpWidget(MyApp(...))` reuses the first
/// `SettingsController` instead of picking up a new persistence instance.
void main() {
  Widget buildApp(MemoryOnlySettingsPersistence settingsPersistence) {
    return MyApp(
      settingsPersistence: settingsPersistence,
      playerProgressPersistence: MemoryOnlyPlayerProgressPersistence(),
      adsController: null,
      gamesServicesController: null,
      inAppPurchaseController: null,
      customVersesController: CustomVersesController(
        store: MemoryCustomVersesPersistence(),
        api: BollsBibleApiClient(),
      ),
    );
  }

  testWidgets(
      'with no stored choice and an English device locale, starts English '
      '(regression: used to always start German)', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await loadCuratedVerses();

    await tester.pumpWidget(buildApp(MemoryOnlySettingsPersistence()));
    await tester.pump();

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Spielen'), findsNothing);
  });
}
