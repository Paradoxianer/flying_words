import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/random_words.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';

class FlyingWord extends StatefulWidget {
  final Duration duration;
  final Lesson lesson;
  final LevelState state;
  final numberFlyingWords;

  FlyingWord({
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
  late int _correctWordIndex = widget.numberFlyingWords;

  double _radius = 0.0;
  List<String> get _words => widget.lesson.words;

  void _textWordsList() {
    _allWords = _words;
    _allAngles = List<double>.empty(growable: true);
    final double angleSlice = (2 * pi) / (_allWords.length + 1);
    for (int i = 0; i < _allWords.length+1; i++) {
      double angle = angleSlice * i-(pi/2);
      _allAngles.add(angle);
    }
    _wordIndexes = List.generate(_allWords.length, (index) => index);
  }


    void _randomWordsList(int howMany) {
    _allWords = List<String>.empty(growable: true);
    _allAngles = List<double>.empty(growable: true);
    final random = Random();
    final double angleSlice = (2 * pi) / (howMany+1);
    for (int i = 0; i < howMany; i++) {
      int index = random.nextInt(bibleWords.length);
      //first calculate the in how many Parts we need to split up 2pi circle
      //TODO maybe add a little random degree to it.
      double angle = angleSlice * i;
      _allAngles.add(angle);
      // if we got the same word out of the list we choose a new random index
      if (bibleWords[index] == _words[widget.state.wordIndex])
        index = random.nextInt(bibleWords.length);
      _allWords.add(bibleWords[index]);
    }
    _allWords.add(_words[widget.state.wordIndex]);
    _allAngles.add(angleSlice * howMany);
    _wordIndexes = List.generate(_allWords.length, (index) => index);
    _wordIndexes.shuffle();
  }

  void _nextWord() {
    widget.state.nextWordIndex();
    widget.state.evaluate();
    //next Word
    _radius = 0.0;
    //generate Random Word List
    if (widget.state.wordIndex>=widget.lesson.words.length)
      _textWordsList();
    else
      _randomWordsList(widget.numberFlyingWords);
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
        _nextWord();
      }
    }
    );
    super.initState();
    Future.delayed(Duration(milliseconds: 800), () {
      _controller.forward();
    });
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
    final audioController = context.read<AudioController>();
    final angle = _allAngles[_wordIndexes[index]];
    final dx = _radius * cos(angle);
    final dy = _radius * sin(angle)*MediaQuery.of(context).size.aspectRatio;
    return Align(
        alignment: Alignment(dx,dy),
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (index == _correctWordIndex) {
                print("correkt Wort");
                audioController.playSfx(SfxType.swishSwish);
                _nextWord();
              } else {
                print("falsches Wort");
                audioController.playSfx(SfxType.huhsh);
              }
            });
          },
          child: Text(_allWords[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  decoration: TextDecoration.none)),
        ));
  }

  @override
  Widget build(BuildContext context) {
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
