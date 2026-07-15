// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../game_internals/lesson.dart';
import '../games_services/score.dart';
import '../level_selection/levels.dart';
import '../level_selection/wax_seal.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import '../style/scriptorium_text.dart';
import '../verses/custom_verses_controller.dart';

/// One finished run: which verse and seal it was on, and the score earned.
class _Run {
  final Lesson lesson;
  final Difficulty difficulty;
  final Score score;

  const _Run(this.lesson, this.difficulty, this.score);
}

/// The device-local leaderboard (#14, "Stufe 1"): no account needed, ranks
/// the player's own best runs across every verse and seal, plus their
/// all-time total score. Online leaderboards (Play Games / Game Center,
/// "Stufe 2") are a separate, later step - see the issue.
class LocalLeaderboardScreen extends StatelessWidget {
  const LocalLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;
    final playerProgress = context.watch<PlayerProgress>();
    final customVerses = context.watch<CustomVersesController>();

    final allLessons = [...gameLevels, ...customVerses.verses];
    final runs = <_Run>[];
    for (final lesson in allLessons) {
      final verseProgress =
          playerProgress.progressForVerse(verseProgressKey(lesson));
      for (final difficulty in Difficulty.values) {
        final score = verseProgress[difficulty];
        if (score != null && score.score > 0) {
          runs.add(_Run(lesson, difficulty, score));
        }
      }
    }
    runs.sort((a, b) => b.score.score.compareTo(a.score.score));
    final memorizedCount = playerProgress
        .memorizedVerseCount(allLessons.map(verseProgressKey).toList());

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.leaderboard,
              textAlign: TextAlign.center,
              style:
                  ScriptoriumText.display.copyWith(color: palette.inkFullOpacity),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.leaderboardTotalScore(playerProgress.playerScore),
              textAlign: TextAlign.center,
              style: ScriptoriumText.heading.copyWith(color: palette.gold),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.leaderboardMemorizedVerses(memorizedCount),
              textAlign: TextAlign.center,
              style: ScriptoriumText.body.copyWith(color: palette.inkFaded),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: runs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          l10n.leaderboardEmpty,
                          textAlign: TextAlign.center,
                          style: ScriptoriumText.body
                              .copyWith(color: palette.inkFaded),
                        ),
                      ),
                    )
                  : ListView.builder(
                      key: const Key('leaderboard-list'),
                      itemCount: runs.length,
                      itemBuilder: (context, index) =>
                          _RunRow(rank: index + 1, run: runs[index]),
                    ),
            ),
          ],
        ),
        rectangularMenuArea: FilledButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          child: Text(l10n.back),
        ),
      ),
    );
  }
}

class _RunRow extends StatelessWidget {
  final int rank;
  final _Run run;

  const _RunRow({required this.rank, required this.run});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$rank.',
              style: ScriptoriumText.body.copyWith(color: palette.inkFaded),
            ),
          ),
          Expanded(
            child: Text(
              '${run.lesson.verse} · ${sealNumerals[run.difficulty]}',
              style: ScriptoriumText.body.copyWith(color: palette.inkFullOpacity),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${run.score.score}',
            style: ScriptoriumText.heading
                .copyWith(fontSize: 18, color: palette.gold),
          ),
        ],
      ),
    );
  }
}
