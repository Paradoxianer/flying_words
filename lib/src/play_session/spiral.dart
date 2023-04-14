import 'dart:math';

import 'package:flutter/material.dart';

class Spiral extends StatefulWidget {
  final String text;
  final double speed;

  Spiral({required this.text,  this.speed=0.01});

  @override
  _SpiralState createState() => _SpiralState();
}

class _SpiralState extends State<Spiral> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  late List<double> _delays;

  late MediaQueryData _mediaQueryData;
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;

  List<String> get _words => widget.text.split(' ');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(() {
      setState(() {});
    });

    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;

    _animations = List.generate(_words.length, (index) {
      final distance = _screenWidth / 2 - 50 - (index * 10);
      final durationInSeconds = distance / widget.speed;
      final duration = Duration(seconds: durationInSeconds.toInt());

      return Tween(begin: 0.0, end: distance).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(_delays[index], 1.0, curve: Curves.easeInOut),
        ),
      );
    });

    _delays = List.generate(_words.length, (index) {
      return index * 0.5;
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
    _mediaQueryData = MediaQuery.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          for (var i = 0; i < _words.length; i++)
            Positioned(
              left: _screenWidth / 2 +
                  _animations[i].value * cos(i * pi / 2),
              top: _screenHeight / 2 -
                  _animations[i].value * sin(i * pi / 2),
              child: Transform.scale(
                scale: 1 + _animations[i].value / _screenWidth,
                child: Text(
                  _words[i],
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
