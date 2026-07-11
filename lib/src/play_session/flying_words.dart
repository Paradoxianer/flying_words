import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/random_words.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';

class FlyingWord extends StatefulWidget {
  final Duration duration;
  final Lesson lesson;
  final LevelState state;
  final numberFlyingWords;

  const FlyingWord({super.key,
    required this.state,
    required this.lesson,
    this.duration = const Duration(seconds: 15),
    this.numberFlyingWords = 10,
  });

  @override
  _FlyingWordState createState() => _FlyingWordState();
}

class _FlyingWordState extends State<FlyingWord> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;
  late List<String> _allWords;
  late List<double> _allAngles;
  late List<int> _wordIndexes;
  // Index of the correct word within [_allWords]; set by [_randomWordsList].
  late int _correctWordIndex;

  /// Words of the current round that were tapped although they were wrong:
  /// they get an ink blot and stop reacting, so the same mistake cannot be
  /// tapped twice.
  final Set<int> _misTapped = {};

  // Feedback popup for a correctly caught word.
  String? _caughtWord;
  Alignment _caughtAlignment = Alignment.center;
  int _caughtTick = 0;

  double _radius = 0.0;
  List<String> get _words => widget.lesson.words;

  void _textWordsList() {
    _allWords = _words;
    _misTapped.clear();
    _allAngles = List<double>.empty(growable: true);
    final double angleSlice = (2 * pi) / (_allWords.length + 1);
    for (int i = 0; i < _allWords.length + 1; i++) {
      double angle = angleSlice * i - (pi / 2);
      _allAngles.add(angle);
    }
    _wordIndexes = List.generate(_allWords.length, (index) => index);
  }

  void _randomWordsList(int howMany) {
    final currentWord = _words[widget.state.wordIndex];
    _misTapped.clear();
    // Draw without replacement so neither the correct word nor any
    // distraction word can show up twice on the screen.
    final candidates =
        bibleWords.where((word) => word != currentWord).toSet().toList()
          ..shuffle();
    _allWords = candidates.take(howMany).toList();
    _allWords.add(currentWord);
    _correctWordIndex = _allWords.length - 1;
    _allAngles = List<double>.empty(growable: true);
    //first calculate the in how many Parts we need to split up 2pi circle
    //TODO maybe add a little random degree to it.
    final double angleSlice = (2 * pi) / _allWords.length;
    for (int i = 0; i < _allWords.length; i++) {
      _allAngles.add(angleSlice * i);
    }
    _wordIndexes = List.generate(_allWords.length, (index) => index);
    _wordIndexes.shuffle();
  }

  void _nextWord() {
    widget.state.nextWordIndex();
    widget.state.evaluate();
    //next Word
    _radius = 0.0;
    //generate Random Word List
    if (widget.state.wordIndex >= widget.lesson.words.length) {
      _textWordsList();
    } else {
      _randomWordsList(widget.numberFlyingWords);
    }
    //restart Animation Controller
    _controller.reset();
    _controller.forward();
  }

  @override
  void initState() {
    _randomWordsList(widget.numberFlyingWords);
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: 0.1,
      end: 1.15,
    ).animate(_controller)
      ..addListener(() {
        setState(() {
          // Berechne die aktuelle Entfernung basierend auf der Animation
          _radius = _animation.value;
        });
      });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // After the win the words of the verse fly out once more as part of
        // the celebration; that run must not count as an error.
        if (widget.state.wordIndex < widget.lesson.words.length) {
          //since the right word wasnt selected this counts as error
          widget.state.addErrorIndex(widget.state.wordIndex);
          _nextWord();
        }
      }
    });
    widget.state.addListener(_onPauseChanged);
    super.initState();
    Future.delayed(Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (!widget.state.paused) {
        _controller.forward();
      }
    });
  }

  /// Freezes the flight while the game is paused and resumes it afterwards.
  void _onPauseChanged() {
    if (!mounted) return;
    if (widget.state.paused) {
      if (_controller.isAnimating) {
        _controller.stop(canceled: false);
      }
    } else if (!_controller.isAnimating &&
        widget.state.wordIndex < widget.lesson.words.length) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_onPauseChanged);
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWord(int index, double aspectRatio, Palette palette) {
    final audioController = context.read<AudioController>();
    final angle = _allAngles[_wordIndexes[index]];
    // Direction in alignment space; the aspect ratio factor makes the
    // words travel a circular path in pixels.
    final ux = cos(angle);
    final uy = sin(angle) * aspectRatio;
    // Normalize so every word reaches the edge of the play area exactly
    // when the animation completes. Without this, the time a word stays
    // visible depends on its direction and the screen size - on a wide
    // fullscreen window vertical words left the screen in half the time.
    final edge = max(ux.abs(), uy.abs());
    final dx = _radius * ux / edge;
    final dy = _radius * uy / edge;
    final misTapped = _misTapped.contains(index);

    final word = Text(
      _allWords[index],
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: bodyFontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 22,
        color: misTapped ? palette.sealRed : palette.inkFullOpacity,
        decoration: TextDecoration.none,
      ),
    );

    return Align(
        alignment: Alignment(dx, dy),
        child: GestureDetector(
          onTap: misTapped
              ? null
              : () {
                  setState(() {
                    if (index == _correctWordIndex) {
                      widget.state.registerCatch();
                      // Remember where the word was caught for the popup.
                      _caughtWord = _allWords[index];
                      _caughtAlignment = Alignment(dx, dy);
                      _caughtTick++;
                      audioController.playSfx(SfxType.swishSwish);
                      _nextWord();
                    } else {
                      _misTapped.add(index);
                      widget.state.addErrorIndex(widget.state.wordIndex);
                      audioController.playSfx(SfxType.huhsh);
                    }
                  });
                },
          child: misTapped
              // A wrongly tapped word gets an ink blot and fades out.
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.sealRed.withValues(alpha: 0.15),
                  ),
                  child: Opacity(opacity: 0.55, child: word),
                )
              : word,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    if (widget.state.paused) {
      // Hide the words while paused - otherwise the pause dialog would be
      // a free peek at the right answer.
      return Container(
        color: palette.parchmentLight,
        alignment: Alignment.center,
        child: Text(
          'Pausiert',
          style: ScriptoriumText.heading.copyWith(color: palette.inkFaded),
        ),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      // Use the aspect ratio of the actual play area, not of the whole
      // screen - the words fly inside this widget.
      final aspectRatio = constraints.maxHeight > 0
          ? constraints.maxWidth / constraints.maxHeight
          : 1.0;
      return Container(
        color: palette.parchmentLight,
        child: Stack(
          children: [
            for (int index = 0; index < _allWords.length; index++)
              _buildWord(index, aspectRatio, palette),
            if (_caughtWord != null)
              _CaughtWordPopup(
                key: ValueKey(_caughtTick),
                word: _caughtWord!,
                combo: widget.state.streak,
                alignment: _caughtAlignment,
                color: palette.gold,
              ),
          ],
        ),
      );
    });
  }
}

/// A short golden popup where the player caught the right word; from the
/// second catch in a row it also celebrates the combo ("x3").
class _CaughtWordPopup extends StatelessWidget {
  final String word;
  final int combo;
  final Alignment alignment;
  final Color color;

  const _CaughtWordPopup({
    super.key,
    required this.word,
    required this.combo,
    required this.alignment,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        return Align(
          alignment: Alignment(alignment.x, alignment.y - 0.25 * t),
          child: Opacity(
            opacity: (1 - t).clamp(0, 1),
            child: child,
          ),
        );
      },
      child: Text(
        combo >= 2 ? '$word  ×$combo' : word,
        style: TextStyle(
          fontFamily: displayFontFamily,
          fontWeight: FontWeight.w700,
          // A long combo pops a little bigger.
          fontSize: combo >= 2 ? 30 : 26,
          color: color,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
