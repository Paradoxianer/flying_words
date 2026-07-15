// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The three device-independent leaderboards decided on in #14 ("Stufe 2"):
/// total score, best single run (on any one verse/seal), and how many
/// verses are mastered "by heart" (all 3 stars on Seal II).
///
/// A fourth category was deliberately left out for now - easy to add later
/// as another [LeaderboardCategory] value without touching the others.
enum LeaderboardCategory { totalScore, bestSingleRun, versesMemorized }

/// Play Games/Game Center leaderboard IDs, one place to fill in once you've
/// created them in Play Console and App Store Connect (see the #14 issue
/// for the step-by-step setup guide) - like [ProviderInfo] does for the
/// legal screens (#18).
class LeaderboardIds {
  static const _ids = <LeaderboardCategory, (String android, String ios)>{
    // Android-IDs aus Play Console (Kommentar auf #14, 15.07.2026).
    LeaderboardCategory.totalScore: (
      'CgkIuYao_PULEAIQAQ',
      '[PLATZHALTER: iOS-Leaderboard-ID für Gesamtpunktzahl]',
    ),
    LeaderboardCategory.bestSingleRun: (
      'CgkIuYao_PULEAIQAg',
      '[PLATZHALTER: iOS-Leaderboard-ID für besten Einzellauf]',
    ),
    LeaderboardCategory.versesMemorized: (
      'CgkIuYao_PULEAIQAw',
      '[PLATZHALTER: iOS-Leaderboard-ID für auswendig gelernte Verse]',
    ),
  };

  static String android(LeaderboardCategory category) =>
      _ids[category]!.$1;

  static String ios(LeaderboardCategory category) => _ids[category]!.$2;
}
