import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';

import '../game_internals/level_state.dart';

class TextProgress extends StatefulWidget {
  final LevelState state;
  final Lesson lesson;

  TextProgress({required this.lesson,required this.state});

  @override
  _TextProgressState createState() => _TextProgressState();

}

class _TextProgressState extends State<TextProgress> {
  List<String> get _words => widget.lesson.words;
  TextStyle _textStyle = TextStyle(
    fontSize: 26,
  );

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onIndexChanged);
  }

    @override
  Widget build(BuildContext context) {
    int currentIndex = widget.state.wordIndex;

    String done ="";
    String current = "";
    String coming ="";
      TextStyle doneStyle = _textStyle.merge(TextStyle(color: Colors.black38));
      TextStyle currentStyle = _textStyle.merge(
          TextStyle(backgroundColor: Colors.red));
      TextStyle commingStyle = _textStyle.merge(TextStyle(color: Colors.black));

  if (currentIndex < widget.lesson.words.length) {
      current=_words[currentIndex];
      for (int i=0;i<currentIndex;i++){
        done += _words[i] + " ";
      }
      for (int i=currentIndex+1;i<_words.length;i++){
        coming += _words[i] + " ";
      }
    }
  else {
    current=widget.lesson.text;
  }

    return
      Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            const BoxShadow(
              color: Colors.black26,
            ),
            const BoxShadow(
              //we need to tight this to the widget background color
              color: Color(0xffffebb5),
              spreadRadius: -3.0,
              blurRadius: 2.0,
            ),
          ],
        ),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(5.0),
        child: RichText(
        text: TextSpan(
          children:  <TextSpan>[
            TextSpan(text:  done, style: doneStyle),
            TextSpan(text: current, style: currentStyle),
            TextSpan(text: coming, style:commingStyle),
          ],
        ),
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
