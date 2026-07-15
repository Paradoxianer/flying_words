// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/play_session/flying_words.dart';
import 'package:flying_words/src/game_internals/level_state.dart';
import 'package:flying_words/src/play_session/play_scoreboard.dart';
import 'package:flying_words/src/play_session/text_progress.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/games_services.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';
import '../verses/custom_verses_controller.dart';

class PlaySessionScreen extends StatefulWidget {
  final Lesson lesson;
  final Difficulty difficulty;

  /// Start with the verse text hidden (chosen via the eye toggle in the
  /// level selection) - the run qualifies for the blind bonus from word one.
  final bool startBlind;

  const PlaySessionScreen(this.lesson, this.difficulty,
      {super.key, this.startBlind = false});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 4000);
  static const _preCelebrationDuration = Duration(milliseconds: 100);

  bool _duringCelebration = false;

  /// Resolved early by [_skipCelebration] when the player taps during the
  /// celebration, so they don't have to sit through it every single win
  /// (#69) - most useful on longer verses seen many times while practicing.
  Completer<void>? _celebrationWait;

  late DateTime _startOfPlay;

  // Time spent in pause dialogs/settings; subtracted from the run time so
  // pausing neither helps nor hurts the score.
  Duration _pausedTotal = Duration.zero;
  DateTime? _pauseStarted;

  void _setPaused(LevelState levelState, bool paused) {
    if (paused) {
      _pauseStarted ??= DateTime.now();
    } else if (_pauseStarted != null) {
      _pausedTotal += DateTime.now().difference(_pauseStarted!);
      _pauseStarted = null;
    }
    levelState.setPaused(paused);
  }

  /// Pauses the game and asks before throwing away the round's progress.
  Future<void> _confirmLeave(BuildContext context) async {
    if (_duringCelebration) return;
    final levelState = context.read<LevelState>();
    _setPaused(levelState, true);
    final l10n = AppLocalizations.of(context)!;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.endRoundTitle),
        content: Text(l10n.endRoundBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepPlaying),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.endRound),
          ),
        ],
      ),
    );
    if (!mounted || !context.mounted) return;
    if (leave == true) {
      GoRouter.of(context).go('/play');
    } else {
      _setPaused(levelState, false);
    }
  }

  /// Opens the settings; the game pauses while they are visible.
  Future<void> _openSettings(BuildContext context) async {
    final levelState = context.read<LevelState>();
    _setPaused(levelState, true);
    await GoRouter.of(context).push('/settings');
    if (!mounted) return;
    _setPaused(levelState, false);
  }

  /// Waits for [duration], but resolves early if [_skipCelebration] is
  /// called in the meantime.
  Future<void> _waitOrSkip(Duration duration) async {
    final completer = Completer<void>();
    _celebrationWait = completer;
    final timer = Timer(duration, () {
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
    timer.cancel();
    _celebrationWait = null;
  }

  void _skipCelebration() {
    final wait = _celebrationWait;
    if (wait != null && !wait.isCompleted) wait.complete();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final state = LevelState(
              length: widget.lesson.words.length,
              onWin: _playerWon,
            );
            if (widget.startBlind) {
              state.setTextHidden(true);
            }
            return state;
          },
        ),
      ],
      child: Builder(builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _confirmLeave(context);
          },
          child: Scaffold(
            backgroundColor: palette.backgroundPlaySession,
            body: Stack(
              children: [
                IgnorePointer(
                  ignoring: _duringCelebration,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Consumer<LevelState>(
                                builder: (context, levelState, child) =>
                                    PlayScoreboard(
                                  state: levelState,
                                  wordCount: widget.lesson.words.length,
                                ),
                              ),
                            ),
                            InkResponse(
                              onTap: () => _openSettings(context),
                              child: Image.asset(
                                'assets/images/settings.png',
                                semanticLabel: l10n.settings,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<LevelState>(
                        builder: (context, levelState, child) => TextProgress(
                            lesson: widget.lesson, state: levelState),
                      ),
                      Consumer<LevelState>(
                        builder: (context, levelState, child) => Expanded(
                          child: Stack(
                            children: [
                              FlyingWord(
                                  lesson: widget.lesson,
                                  state: levelState,
                                  duration: difficultySpeed[widget.difficulty] ??
                                      Duration(seconds: 7),
                                  numberFlyingWords:
                                      difficultyWordcount[widget.difficulty]),
                              // Confined to the play area, not the whole
                              // screen (#69).
                              Visibility(
                                visible: _duringCelebration,
                                child: IgnorePointer(
                                  child: Confetti(
                                    isStopped: !_duringCelebration,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _confirmLeave(context),
                            child: Text(l10n.back),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tapping anywhere skips the fixed celebration wait (#69);
                // the game controls underneath stay non-interactive during
                // the celebration either way (see the IgnorePointer above).
                if (_duringCelebration)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _skipCelebration,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            l10n.tapToSkip,
                            style: ScriptoriumText.body
                                .copyWith(color: palette.inkFaded),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
  }

  Future<void> _playerWon(LevelState state) async {
    _log.info('Level ${widget.lesson.verse} won');

    final score = Score.fromResult(
      widget.lesson.words.length,
      widget.difficulty,
      // Time spent in the pause dialog or the settings doesn't count.
      DateTime.now().difference(_startOfPlay) - _pausedTotal,
      state.numErrors,
      blindBonus: state.blindRun,
    );

    final playerProgress = context.read<PlayerProgress>();
    final progressKey = verseProgressKey(widget.lesson);
    // Remember the best run before this one, for the comparison on the
    // win screen ("Neue Bestzeit!").
    final previousBest =
        playerProgress.getScoreforVerse(progressKey, widget.difficulty);
    playerProgress.setScoreforVerse(progressKey, widget.difficulty, score);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    final gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      // Award achievement.
      /*ToDo implement
      if (widget.level.awardsAchievement) {
        await gamesServicesController.awardAchievement(
          android: widget.level.achievementIdAndroid!,
          iOS: widget.level.achievementIdIOS!,
        );
      }*/

      // Send the new standing to every leaderboard (#14).
      final customVerses = context.read<CustomVersesController>();
      final allVerseKeys = [...gameLevels, ...customVerses.verses]
          .map(verseProgressKey)
          .toList();
      await gamesServicesController.submitAllLeaderboardScores(
        totalScore: playerProgress.playerScore,
        bestSingleRunScore: playerProgress.bestSingleRunScore,
        memorizedVerseCount:
            playerProgress.memorizedVerseCount(allVerseKeys),
      );
    }

    /// Give the player some time to see the celebration animation - unless
    /// they tap to skip ahead (#69).
    await _waitOrSkip(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {
      'score': score,
      'levelState': state,
      'lesson': widget.lesson,
      'difficulty': widget.difficulty,
      'previousBest': previousBest,
    });
  }
}
