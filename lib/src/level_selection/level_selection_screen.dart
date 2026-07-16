// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flying_words/src/level_selection/level_item.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../challenges/challenges_tab.dart';
import '../currency/gold_ink.dart';
import '../game_internals/lesson.dart';
import '../player_progress/player_progress.dart';
import '../shop/shop_tab.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import '../style/scriptorium_text.dart';
import '../verses/custom_verses_controller.dart';
import '../verses/verse_picker.dart';
import 'levels.dart';
import 'sealed_verse_card.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: palette.backgroundLevelSelection,
        body: ResponsiveScreen(
          squarishMainArea: Column(
            children: [
              // Compact: title and Goldtinte balance share one row instead
              // of stacking with large gaps (#107).
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.chooseChallenge,
                        style: ScriptoriumText.verseRef
                            .copyWith(color: palette.inkFullOpacity),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer<GoldInkController>(
                      builder: (context, goldInk, child) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 16, color: palette.gold),
                          const SizedBox(width: 4),
                          Text(
                            l10n.goldInkBalance(goldInk.balance),
                            key: const Key('gold-ink-balance'),
                            style: ScriptoriumText.label
                                .copyWith(color: palette.gold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: palette.gold,
                unselectedLabelColor: palette.inkFaded,
                indicatorColor: palette.gold,
                tabs: [
                  Tab(text: l10n.levelSelectionVersesTab),
                  Tab(text: l10n.challenges),
                  Tab(text: l10n.shop),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    _VersesTab(),
                    ChallengesTab(),
                    ShopTab(),
                  ],
                ),
              ),
            ],
          ),
          rectangularMenuArea: ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            child: Text(l10n.back),
          ),
        ),
      ),
    );
  }
}

class _VersesTab extends StatelessWidget {
  const _VersesTab();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    final customVerses = context.watch<CustomVersesController>();
    final l10n = AppLocalizations.of(context)!;
    final orderedVerses = [
      for (final level in gameLevels) verseProgressKey(level)
    ];
    final unlockedCount = playerProgress.unlockedVerseCount(orderedVerses);
    // Own verses open once the whole curated list is finished on seal I.
    final ownVersesUnlocked =
        customVersesUnlocked(orderedVerses, playerProgress);

    return ListView(
      children: [
        for (var i = 0; i < gameLevels.length; i++)
          if (i < unlockedCount)
            LevelItem(gameLevels[i])
          else
            // Locked verses stay visible as sealed cards so the player
            // sees there is more to unlock (#52).
            SealedVerseCard(
              key: Key('sealed-${gameLevels[i].number}'),
              // The very next verse hints at how to open it.
              isNext: i == unlockedCount,
            ),
        if (ownVersesUnlocked) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.ownVerses,
              style: ScriptoriumText.heading
                  .copyWith(color: palette.inkFullOpacity),
            ),
          ),
          for (final verse in customVerses.verses)
            // Fully mastered (Seal III) verses collapse into a closed
            // section instead - with no cap on how many verses can be
            // added, the list otherwise just keeps growing with verses
            // the player no longer needs to see at a glance (#80).
            if (!playerProgress
                .progressForVerse(verseProgressKey(verse))
                .finished(Difficulty.insane))
              LevelItem(verse),
          if (customVerses.verses.any((verse) => playerProgress
              .progressForVerse(verseProgressKey(verse))
              .finished(Difficulty.insane)))
            _FinishedOwnVerses(
              verses: customVerses.verses
                  .where((verse) => playerProgress
                      .progressForVerse(verseProgressKey(verse))
                      .finished(Difficulty.insane))
                  .toList(),
              l10n: l10n,
              palette: palette,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton.icon(
              key: const Key('add-verse'),
              onPressed: customVerses.canAddMore(playerProgress)
                  ? () => showVersePicker(context)
                  : null,
              icon: const Icon(Icons.add),
              label: Text(
                customVerses.canAddMore(playerProgress)
                    ? l10n.addVerse
                    : l10n.finishOpenOwnVersesFirst,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A closed-by-default section for own verses already mastered on Seal
/// III, so a long history of finished verses doesn't crowd out the ones
/// still being practiced (#80).
class _FinishedOwnVerses extends StatelessWidget {
  final List<Lesson> verses;
  final AppLocalizations l10n;
  final Palette palette;

  const _FinishedOwnVerses({
    required this.verses,
    required this.l10n,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      // ExpansionTile's default divider lines don't fit the parchment look.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: const Key('finished-own-verses'),
        title: Text(
          l10n.finishedOwnVerses(verses.length),
          style: ScriptoriumText.heading.copyWith(color: palette.inkFaded),
        ),
        children: [for (final verse in verses) LevelItem(verse)],
      ),
    );
  }
}
