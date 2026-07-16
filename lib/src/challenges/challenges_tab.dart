// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../game_internals/lesson.dart';
import '../level_selection/levels.dart';
import '../level_selection/wax_seal.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';
import 'challenges_controller.dart';
import 'challenges_data.dart';

/// The daily verse, the weekly star goal and the play streak (#53 Phase C)
/// - all reward Jokers for coming back and playing. Lives as a tab next to
/// the verse list in [LevelSelectionScreen], not a separate screen (#107).
class ChallengesTab extends StatefulWidget {
  const ChallengesTab({super.key});

  @override
  State<ChallengesTab> createState() => _ChallengesTabState();
}

class _ChallengesTabState extends State<ChallengesTab> {
  @override
  void initState() {
    super.initState();
    final playerProgress = context.read<PlayerProgress>();
    final orderedVerses = [for (final level in gameLevels) verseProgressKey(level)];
    final unlockedCount = playerProgress.unlockedVerseCount(orderedVerses);
    final unlockedVerseNumbers = [
      for (var i = 0; i < unlockedCount; i++) gameLevels[i].number,
    ];
    context.read<ChallengesController>().ensureCurrent(unlockedVerseNumbers);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;
    final challenges = context.watch<ChallengesController>().data;

    Lesson? dailyLesson;
    for (final level in gameLevels) {
      if (level.number == challenges.dailyVerseNumber) {
        dailyLesson = level;
        break;
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      children: [
        if (dailyLesson case final lesson?)
          _ChallengeCard(
            title: l10n.challengesDailyTitle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.verse,
                    style: ScriptoriumText.body
                        .copyWith(color: palette.inkFullOpacity),
                  ),
                ),
                const SizedBox(width: 8),
                if (challenges.dailyClaimed)
                  Text(
                    l10n.challengesDailyDone,
                    style: ScriptoriumText.body.copyWith(color: palette.gold),
                  )
                else
                  FilledButton(
                    onPressed: () => GoRouter.of(context).go(
                        '/play/session/${lesson.number}/${Difficulty.slow.name}'),
                    child: Text(l10n.challengesDailyCta),
                  ),
              ],
            ),
          ),
        if (dailyLesson != null) const SizedBox(height: 10),
        if (challenges.weeklyDifficulty != null)
          _ChallengeCard(
            title: l10n.challengesWeeklyTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.challengesWeeklyBody(
                    challenges.weeklyStars > challenges.weeklyTarget
                        ? challenges.weeklyTarget
                        : challenges.weeklyStars,
                    challenges.weeklyTarget,
                    sealNumerals[challenges.weeklyDifficulty]!,
                  ),
                  style: ScriptoriumText.body.copyWith(color: palette.inkFaded),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenges.weeklyTarget == 0
                        ? 0
                        : (challenges.weeklyStars / challenges.weeklyTarget)
                            .clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: palette.parchmentDark,
                    color: palette.gold,
                  ),
                ),
                if (challenges.weeklyClaimed) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.challengesWeeklyDone,
                    style: ScriptoriumText.body.copyWith(color: palette.gold),
                  ),
                ],
              ],
            ),
          ),
        if (challenges.weeklyDifficulty != null) const SizedBox(height: 10),
        _ChallengeCard(
          title: l10n.challengesStreakTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.challengesStreakBody(challenges.streakDays),
                style: ScriptoriumText.body.copyWith(color: palette.inkFaded),
              ),
              const SizedBox(height: 4),
              Text(
                _nextMilestoneText(l10n, challenges),
                style: ScriptoriumText.body.copyWith(color: palette.gold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _nextMilestoneText(AppLocalizations l10n, ChallengesData challenges) {
    if (!challenges.streak3Claimed) {
      final remaining = 3 - challenges.streakDays;
      return l10n.challengesStreakNext3(remaining < 1 ? 1 : remaining);
    }
    if (!challenges.streak7Claimed) {
      final remaining = 7 - challenges.streakDays;
      return l10n.challengesStreakNext7(remaining < 1 ? 1 : remaining);
    }
    return l10n.challengesStreakMilestonesDone;
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChallengeCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.parchmentLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: palette.inkFullOpacity.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ScriptoriumText.label.copyWith(color: palette.gold),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
