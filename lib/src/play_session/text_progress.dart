import 'package:flutter/material.dart';

class TextProgress extends StatefulWidget {
  final String text;
  final ValueNotifier<int> index;

  TextProgress({required this.text, required this.index});

  @override
  _TextProgressState createState() => _TextProgressState();

}

class _TextProgressState extends State<TextProgress> {
  List<String> get _words => widget.text.split(' ');

  @override
  Widget build(BuildContext context) {
    int currentIndex = widget.index.value;
    String done ="";
    String current = _words[currentIndex];
    String coming ="";

    for (int i=0;i<currentIndex;i++){
      done += _words[i] + " ";
    }

    for (int i=currentIndex+1;i<_words.length;i++){
      coming += _words[i] + " ";
    }
    return RichText(
      text: TextSpan(
        children:  <TextSpan>[
          TextSpan(text:  done,
              style: TextStyle(
                    color: Colors.grey)
            ),
          TextSpan(text: current,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                backgroundColor: Colors.red,
              )),
    TextSpan(text: coming),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.index.addListener(_onIndexChanged);
  }

  @override
  void dispose() {
    widget.index.removeListener(_onIndexChanged);
    super.dispose();
  }

  void _onIndexChanged() {
    setState(() {});
  }
}
