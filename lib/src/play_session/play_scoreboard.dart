import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../game_internals/level_state.dart';

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
    fontFamily: 'Cormorant Garamond', fontWeight: FontWeight.w700,
    fontSize: 20,
    color: Colors.black87,
  );

  late final Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Stop counting once the lesson is finished (celebration).
      if (widget.state.wordIndex < widget.wordCount) {
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
    final currentWord = min(widget.state.wordIndex + 1, widget.wordCount);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _entry(Icons.menu_book, '$currentWord/${widget.wordCount}'),
        _entry(Icons.timer_outlined, _formattedTime),
        _entry(Icons.close, '${widget.state.numErrors}',
            iconColor: Colors.deepOrangeAccent),
      ],
    );
  }

  Widget _entry(IconData icon, String text, {Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: iconColor ?? Colors.black54),
        const SizedBox(width: 4),
        Text(text, style: _textStyle),
      ],
    );
  }
}
