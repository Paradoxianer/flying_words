// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:games_services/games_services.dart' as gs;
import 'package:logging/logging.dart';

import 'leaderboard_ids.dart';

/// Allows awarding achievements and leaderboard scores,
/// and also showing the platforms' UI overlays for achievements
/// and leaderboards.
///
/// A facade of `package:games_services`.
class GamesServicesController {
  static final Logger _log = Logger('GamesServicesController');

  final Completer<bool> _signedInCompleter = Completer();

  Future<bool> get signedIn => _signedInCompleter.future;

  /// Unlocks an achievement on Game Center / Play Games.
  ///
  /// You must provide the achievement ids via the [iOS] and [android]
  /// parameters.
  ///
  /// Does nothing when the game isn't signed into the underlying
  /// games service.
  Future<void> awardAchievement(
      {required String iOS, required String android}) async {
    if (!await signedIn) {
      _log.warning('Trying to award achievement when not logged in.');
      return;
    }

    try {
      await gs.GamesServices.unlock(
        achievement: gs.Achievement(
          androidID: android,
          iOSID: iOS,
        ),
      );
    } catch (e) {
      _log.severe('Cannot award achievement: $e');
    }
  }

  /// Signs into the underlying games service.
  Future<void> initialize() async {
    try {
      await gs.GamesServices.signIn();
      // The API is unclear so we're checking to be sure. The above call
      // returns a String, not a boolean, and there's no documentation
      // as to whether every non-error result means we're safely signed in.
      final signedIn = await gs.GamesServices.isSignedIn;
      _signedInCompleter.complete(signedIn);
    } catch (e) {
      _log.severe('Cannot log into GamesServices: $e');
      _signedInCompleter.complete(false);
    }
  }

  /// Launches the platform's UI overlay with achievements.
  Future<void> showAchievements() async {
    if (!await signedIn) {
      _log.severe('Trying to show achievements when not logged in.');
      return;
    }

    try {
      await gs.GamesServices.showAchievements();
    } catch (e) {
      _log.severe('Cannot show achievements: $e');
    }
  }

  /// Launches the platform's UI overlay listing every leaderboard (#14) -
  /// an empty leaderboard ID shows the full list rather than a single
  /// board.
  Future<void> showLeaderboards() async {
    if (!await signedIn) {
      _log.severe('Trying to show leaderboards when not logged in.');
      return;
    }

    try {
      await gs.GamesServices.showLeaderboards();
    } catch (e) {
      _log.severe('Cannot show leaderboards: $e');
    }
  }

  /// Submits [value] to the [category] leaderboard (#14).
  Future<void> submitLeaderboardScore(
      LeaderboardCategory category, int value) async {
    if (!await signedIn) {
      _log.warning('Trying to submit leaderboard when not logged in.');
      return;
    }

    _log.info('Submitting $value to the $category leaderboard.');

    try {
      await gs.GamesServices.submitScore(
        score: gs.Score(
          iOSLeaderboardID: LeaderboardIds.ios(category),
          androidLeaderboardID: LeaderboardIds.android(category),
          value: value,
        ),
      );
    } catch (e) {
      _log.severe('Cannot submit $category leaderboard score: $e');
    }
  }

  /// Submits the current standing in all three leaderboards (#14): total
  /// score, best single run, and how many verses are memorized. Meant to
  /// be called once after each finished run.
  Future<void> submitAllLeaderboardScores({
    required int totalScore,
    required int bestSingleRunScore,
    required int memorizedVerseCount,
  }) async {
    await submitLeaderboardScore(LeaderboardCategory.totalScore, totalScore);
    await submitLeaderboardScore(
        LeaderboardCategory.bestSingleRun, bestSingleRunScore);
    await submitLeaderboardScore(
        LeaderboardCategory.versesMemorized, memorizedVerseCount);
  }
}
