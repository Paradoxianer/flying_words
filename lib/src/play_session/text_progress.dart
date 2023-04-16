import 'package:flutter/material.dart';

import '../game_internals/level_state.dart';

class TextProgress extends StatefulWidget {
  LevelState state;

  TextProgress({required this.state});

  @override
  _TextProgressState createState() => _TextProgressState();

}

class _TextProgressState extends State<TextProgress> {
  List<String> get _words => widget.state.words;
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

  if (currentIndex < widget.state.words.length) {
      current=_words[currentIndex];
      for (int i=0;i<currentIndex;i++){
        done += _words[i] + " ";
      }
      for (int i=currentIndex+1;i<_words.length;i++){
        coming += _words[i] + " ";
      }
    }
  else {
    current=widget.state.text;
  }

    return RichText(
      text: TextSpan(
        children:  <TextSpan>[
          TextSpan(text:  done, style: doneStyle),
          TextSpan(text: current, style: currentStyle),
          TextSpan(text: coming, style:commingStyle),
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
