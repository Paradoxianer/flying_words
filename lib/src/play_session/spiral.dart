import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_template/src/play_session/random_words.dart';

class Spiral extends StatefulWidget {
  final String text;
  final Duration duration;

  Spiral({required this.text,  this.duration=const Duration(seconds: 15)});
  @override
  _SpiralState createState() => _SpiralState();
}

class _SpiralState extends State<Spiral> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;
  late List<String> _allWords;
  late List<double> _allAngles;
  late List<int> _wordIndexes;
  late double _centerX;
  late double _centerY;
  late int _correctWordIndex = 10;


  double _radius = 0.0;
  int _currentIndex = 0;

  List<String> get _words => widget.text.split(' ');

  void _randomWordsList(int howMany){
    _allWords=List<String>.empty(growable: true);
    _allAngles = List<double>.empty(growable: true);
    final random = Random();
    for (int i = 0; i < howMany; i++) {
      final int index = random.nextInt(bibleWords.length);
      //this need to be adjustes so that in -45 bis 45 nur ein Wort ist und auch in 135 bis 225 and thats it at least more than 0 degree..
      double angle=5+(random.nextDouble()*(360.0/(howMany+1)));
      print(angle);
      if (i>0)
        _allAngles.add(_allAngles[i-1]+angle);
      else
        _allAngles.add(angle);
      if (bibleWords[index]==_words[_currentIndex])
        final int index = random.nextInt(bibleWords.length);
      _allWords.add(bibleWords[index]);
    }
    _allWords.add(_words[_currentIndex]);
    _allAngles.add(5+(random.nextDouble()*(360.0/(howMany+1))-5));
    _wordIndexes = List.generate(_allWords.length, (index) => index);
    _wordIndexes.shuffle();
  }

  void _nextWord(){
    if (_currentIndex<_words.length-1){
      //restart Animation Controller
      _controller.reset();
      _controller.forward();
      //next Word
      _currentIndex++;
      //reset Radius to null
      _radius =0.0;
      //generate Random Word List
      _randomWordsList(10);
    }
  }


  @override
  void initState() {
    super.initState();
    _randomWordsList(10);

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 1.0,end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _radius += 0.5;
          // The state that has changed here is the animation object’s value.
        });
      });
    _animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextWord();
        }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _buildWord(int index) {

    final angle = _allAngles[_wordIndexes[index]];
    final dx = _centerX+_radius * cos(angle);
    final dy = _centerY+_radius * sin(angle);
      return Positioned(
         left: dx,
        top: dy,
         child: GestureDetector(
            onTap: () {
              setState(() {
                if (index == _correctWordIndex) {
                  print("correkt Wort");
                  _nextWord();
                }
                else{
                  print("falsches Wort");
                }
              });
            },
            child: Text(
              _allWords[index],
              style:TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  decoration: TextDecoration.none
              )
            ),
          )
      );
    }

  @override
  Widget build(BuildContext context) {
    _centerX = MediaQuery.of(context).size.width / 2;
    _centerY = MediaQuery.of(context).size.height / 2;
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          for (int index = 0; index < _allWords.length; index++)
            _buildWord(index),
        ],
      ),
    );
  }
}
