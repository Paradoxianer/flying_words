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
  List<TextSpan> styledText = List<TextSpan>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onIndexChanged);
  }

    @override
  Widget build(BuildContext context) {
    styledText.clear();
    int currentIndex = widget.state.wordIndex;

    String done ="";
    String current = "";
    String coming ="";

    TextStyle doneStyle = _textStyle.merge(TextStyle(color: Colors.black38));
    TextStyle doneErrStyle = _textStyle.merge(TextStyle(color: Colors.deepOrangeAccent));
    TextStyle currentStyle = _textStyle.merge(
          TextStyle(backgroundColor: Colors.red));
    TextStyle commingStyle = _textStyle.merge(TextStyle(color: Colors.black));

  if (currentIndex < widget.lesson.words.length) {
      for (int i=0;i<currentIndex;i++){
      if (widget.state.Errors.contains(i)==true){
          styledText.add(TextSpan(text: _words[i]+" ",style: doneErrStyle));
        }
          else{
          styledText.add(TextSpan(text: _words[i]+" ",style: doneStyle));
        }
      }
      styledText.add(TextSpan(text: _words[currentIndex]+" ",style: currentStyle));
      for (int i=currentIndex+1;i<_words.length;i++){
        coming += _words[i] + " ";
      }
      styledText.add(TextSpan(text: coming,style: commingStyle));
    }
  else {
    current=widget.lesson.text;
  }
  debugPrint(styledText.toString());
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
          children:
            styledText.toList()
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
