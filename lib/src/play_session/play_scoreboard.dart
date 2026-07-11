import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/level_state.dart';
import '../style/palette.dart';

/// A small live scoreboard shown during a play session: how far the player
/// is into the verse, the elapsed time and the number of errors so far.
class PlayScoreboard extends StatefulWidget {
  final LevelState state;
  final int wordCount;

  const PlayScoreboard({
    super.key,
    required this.state,
    required this.wordCount,
  });

  @override
  State<PlayScoreboard> createState() => _PlayScoreboardState();
}

class _PlayScoreboardState extends State<PlayScoreboard> {
  static const _textStyle = TextStyle(
    fontFamily: 'Cormorant Garamond',
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  late final Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Stop counting once the lesson is finished (celebration) and
      // while the game is paused.
      if (widget.state.wordIndex < widget.wordCount && !widget.state.paused) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
    widget.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  String get _formattedTime {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final currentWord = min(widget.state.wordIndex + 1, widget.wordCount);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _entry(palette, Icons.menu_book, '$currentWord/${widget.wordCount}'),
        _entry(palette, Icons.timer_outlined, _formattedTime),
        _entry(palette, Icons.close, '${widget.state.numErrors}',
            iconColor: palette.sealRed),
        // The combo only shows once there is one - from two in a row.
        if (widget.state.streak >= 2)
          _entry(palette, Icons.local_fire_department,
              '×${widget.state.streak}',
              iconColor: palette.gold),
      ],
    );
  }

  Widget _entry(Palette palette, IconData icon, String text,
      {Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: iconColor ?? palette.inkFaded),
        const SizedBox(width: 4),
        Text(text,
            style: _textStyle.copyWith(color: palette.inkFullOpacity)),
      ],
    );
  }
}
