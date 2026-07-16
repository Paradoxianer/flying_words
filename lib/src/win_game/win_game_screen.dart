// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../game_internals/lesson.dart';
import '../game_internals/level_state.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../jokers/joker_type.dart';
import '../jokers/joker_type_info.dart';
import '../play_session/text_progress.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';
import '../style/responsive_screen.dart';
import 'win_share.dart';

class WinGameScreen extends StatelessWidget {
  final Score score;
  final Lesson lesson;
  final LevelState levelState;
  final Difficulty difficulty;

  /// The best stored run on this verse/difficulty before this one,
  /// for the time comparison; null on the first win.
  final Score? previousBest;

  /// Goldtinte awarded for this run (#54).
  final int goldInkEarned;

  /// Jokers awarded for this run's daily/weekly challenge, streak
  /// milestone or verse-mastery bonus (#53 Phase C, #112) - shown with a
  /// fly-in animation so a reward earned mid-run doesn't just silently
  /// land in the inventory.
  final List<JokerType> earnedJokers;

  const WinGameScreen({
    super.key,
    required this.score,
    required this.lesson,
    required this.levelState,
    required this.difficulty,
    required this.goldInkEarned,
    this.earnedJokers = const [],
    this.previousBest,
  });

  /// A run only counts as a new best if it actually earned at least one
  /// star (#114) - otherwise a deliberately botched, fast run (every word
  /// left flying past uncaught) could "beat" a slow but flawless one on
  /// time alone, and the very first attempt at a verse would always be
  /// celebrated as a new best regardless of quality.
  bool get _isNewBestTime {
    final earnedStars = VerseProgress.starsForRun(
        difficulty, levelState.numErrors, lesson.words.length);
    if (earnedStars <= 0) return false;
    return previousBest == null || score.duration < previousBest!.duration;
  }

  /// Captures [boundaryKey]'s current content as a PNG and shares it
  /// together with [text] (#6). Falls back to a text-only share if the
  /// capture fails for any reason - the share itself should never crash.
  Future<void> _share(GlobalKey boundaryKey, String text) async {
    try {
      final boundary = boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      await Share.shareXFiles(
        [
          XFile.fromData(bytes, name: 'flying-words.png', mimeType: 'image/png')
        ],
        text: text,
      );
    } catch (_) {
      await Share.share(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;

    final earnedStars = VerseProgress.starsForRun(
        difficulty, levelState.numErrors, lesson.words.length);
    final maxStars = VerseProgress.maxStars(difficulty);

    const gap = SizedBox(height: 10);

    // Captured as an image when sharing (#6); excludes the ad banner and
    // the menu buttons below.
    final shareBoundaryKey = GlobalKey();

    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (adsControllerAvailable && !adsRemoved) ...[
              const Expanded(
                child: Center(
                  child: BannerAdWidget(),
                ),
              ),
            ],
            Flexible(
              child: RepaintBoundary(
                key: shareBoundaryKey,
                child: Container(
                  color: palette.backgroundPlaySession,
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        gap,
                        Center(
                          child: Text(
                            l10n.won,
                            style: ScriptoriumText.display.copyWith(
                                fontSize: 50, color: palette.inkFullOpacity),
                          ),
                        ),
                        // The stars earned in this run.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < maxStars; i++)
                              Icon(
                                i < earnedStars
                                    ? Icons.star
                                    : Icons.star_border,
                                key:
                                    i < earnedStars ? Key('won-star-$i') : null,
                                size: 42,
                                color: i < earnedStars
                                    ? palette.gold
                                    : palette.inkFaded,
                              ),
                          ],
                        ),
                        if (levelState.blindRun)
                          Center(
                            child: Text(
                              l10n.blindBonusEarned,
                              style: ScriptoriumText.label
                                  .copyWith(color: palette.gold),
                            ),
                          ),
                        gap,
                        Center(
                          child: Text(
                            lesson.verse,
                            style: ScriptoriumText.verseRef
                                .copyWith(color: palette.inkFullOpacity),
                          ),
                        ),
                        gap,
                        // The whole verse once more, with the missed words
                        // highlighted, so the player sees what to practice.
                        // No Flexible/scroll wrapper of its own needed - the
                        // whole content column already scrolls as one.
                        TextProgress(lesson: lesson, state: levelState),
                        gap,
                        Center(
                          child: Text(
                            l10n.statsBlock(score.score, levelState.numErrors,
                                score.formattedTime),
                            textAlign: TextAlign.center,
                            style: ScriptoriumText.label
                                .copyWith(color: palette.inkFaded),
                          ),
                        ),
                        // No line at all for a non-flawless run: only
                        // flawless runs earn Goldtinte now (#54), and
                        // "+0 Goldtinte" would just read as broken.
                        if (goldInkEarned > 0)
                          Center(
                            child: Text(
                              l10n.goldInkEarned(goldInkEarned),
                              key: const Key('gold-ink-earned'),
                              style: ScriptoriumText.label
                                  .copyWith(color: palette.gold),
                            ),
                          ),
                        if (earnedJokers.isNotEmpty) ...[
                          gap,
                          Center(
                            child: Text(
                              l10n.challengeRewardEarned(earnedJokers.length),
                              style: ScriptoriumText.label
                                  .copyWith(color: palette.gold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            key: const Key('earned-jokers'),
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              for (var i = 0; i < earnedJokers.length; i++)
                                _EarnedJokerBadge(
                                  type: earnedJokers[i],
                                  delay: Duration(milliseconds: 200 * i),
                                ),
                            ],
                          ),
                        ],
                        // Achieved time compared to the best run so far -
                        // nothing to say if this is a zero-star first
                        // attempt, there's no best time to compare to (#114).
                        if (_isNewBestTime || previousBest != null)
                          Center(
                            child: Text(
                              _isNewBestTime
                                  ? l10n.newBestTime
                                  : l10n.bestTime(previousBest!.formattedTime),
                              style: ScriptoriumText.label.copyWith(
                                color: _isNewBestTime
                                    ? palette.gold
                                    : palette.inkFaded,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        rectangularMenuArea: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final text = winShareText(
                    verse: lesson.verse,
                    stars: earnedStars,
                    maxStars: maxStars,
                    score: score.score,
                    blindRun: levelState.blindRun,
                  );
                  _share(shareBoundaryKey, text);
                },
                icon: const Icon(Icons.share),
                label: Text(l10n.share),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  GoRouter.of(context).go('/play');
                },
                child: Text(l10n.continueLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One earned Joker, flying in with a short delay so a multi-Joker reward
/// reads as several distinct catches rather than one flat block (#112).
class _EarnedJokerBadge extends StatefulWidget {
  final JokerType type;
  final Duration delay;

  const _EarnedJokerBadge({required this.type, required this.delay});

  @override
  State<_EarnedJokerBadge> createState() => _EarnedJokerBadgeState();
}

class _EarnedJokerBadgeState extends State<_EarnedJokerBadge> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;
    return AnimatedScale(
      scale: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.gold.withValues(alpha: 0.2),
                border: Border.all(color: palette.gold, width: 2),
              ),
              child:
                  Icon(jokerIcon(widget.type), color: palette.gold, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              jokerName(l10n, widget.type),
              style: ScriptoriumText.body
                  .copyWith(fontSize: 12, color: palette.inkFaded),
            ),
          ],
        ),
      ),
    );
  }
}
