// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flying_words/l10n/gen/app_localizations.dart';

/// A `MaterialApp` with the app's localization delegates wired up, for
/// widget tests that build a single screen/widget in isolation and don't go
/// through `MyApp`'s router (which already sets this up).
class LocalizedMaterialApp extends StatelessWidget {
  final Widget home;

  const LocalizedMaterialApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Matches the app's own default (SettingsController.locale) so tests
      // see German text regardless of the test runner's platform locale.
      locale: const Locale('de'),
      home: home,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
