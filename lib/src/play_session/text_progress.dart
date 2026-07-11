import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:provider/provider.dart';

import '../game_internals/level_state.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';

class TextProgress extends StatefulWidget {
  final LevelState state;
  final Lesson lesson;

  const TextProgress({super.key, required this.lesson, required this.state});

  @override
  _TextProgressState createState() => _TextProgressState();
}

class _TextProgressState extends State<TextProgress> {
  List<String> get _words => widget.lesson.words;
  final TextStyle _textStyle = const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 24,
    height: 1.4,
  );
  List<TextSpan> styledText = List<TextSpan>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onIndexChanged);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    styledText.clear();
    int currentIndex = widget.state.wordIndex;

    String coming = "";

    // Written words fade like dried ink; mistakes stay sealing-wax red.
    TextStyle doneStyle = _textStyle.merge(TextStyle(color: palette.inkFaded));
    TextStyle doneErrStyle = _textStyle.merge(TextStyle(color: palette.sealRed));
    TextStyle currentStyle = _textStyle.merge(TextStyle(
      color: palette.inkFullOpacity,
      fontWeight: FontWeight.w600,
      backgroundColor: palette.goldBright.withValues(alpha: 0.55),
    ));
    TextStyle commingStyle = _textStyle.merge(TextStyle(color: palette.ink));

    if (currentIndex < widget.lesson.words.length) {
      for (int i = 0; i < currentIndex; i++) {
        if (widget.state.Errors.contains(i) == true) {
          styledText.add(TextSpan(text: "${_words[i]} ", style: doneErrStyle));
        } else {
          styledText.add(TextSpan(text: "${_words[i]} ", style: doneStyle));
        }
      }
      styledText
          .add(TextSpan(text: "${_words[currentIndex]} ", style: currentStyle));
      for (int i = currentIndex + 1; i < _words.length; i++) {
        coming += "${_words[i]} ";
      }
      styledText.add(TextSpan(text: coming, style: commingStyle));
    } else {
      // The lesson is finished: show the whole verse and highlight the
      // words that were missed, so the player knows what to practice.
      for (int i = 0; i < _words.length; i++) {
        styledText.add(TextSpan(
          text: "${_words[i]} ",
          style: widget.state.Errors.contains(i) ? doneErrStyle : commingStyle,
        ));
      }
    }

    final playing = currentIndex < widget.lesson.words.length;
    final hidden = widget.state.textHidden && playing;

    return Container(
      decoration: BoxDecoration(
        color: palette.parchmentLight,
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: palette.inkFullOpacity.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.all(6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: hidden
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Text verdeckt — aus dem Gedächtnis! (Score ×1,5)',
                      style: ScriptoriumText.verse
                          .copyWith(color: palette.inkFaded),
                    ),
                  )
                : RichText(
                    text: TextSpan(children: styledText.toList()),
                  ),
          ),
          // The eye toggles the "no cheat sheet" mode (#27); hidden from
          // the very first word on, the run earns the blind bonus.
          if (playing)
            InkWell(
              onTap: () => widget.state.setTextHidden(!hidden),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  hidden ? Icons.visibility_off : Icons.visibility,
                  key: Key(hidden ? 'text-hidden' : 'text-visible'),
                  size: 24,
                  color: palette.inkFaded,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.state.removeListener(_onIndexChanged);
    super.dispose();
  }

  void _onIndexChanged() {
    setState(() {});
  }
}
