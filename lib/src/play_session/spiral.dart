import 'dart:math';

import 'package:flutter/material.dart';

class Spiral extends StatefulWidget {
  final String text;
  final Duration duration;

  Spiral({required this.text,  this.duration=const Duration(seconds: 5)});
  @override
  _SpiralState createState() => _SpiralState();
}

class _SpiralState extends State<Spiral> with TickerProviderStateMixin {
  late MediaQueryData _mediaQueryData;
  late Animation<double> _animation;
  late AnimationController _controller;
  double _radius = 0.0;
  double _angle = 50.0;
  int _currentIndex = 0;

  List<String> get _words => widget.text.split(' ');

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 1.0,end: 360.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _radius += 0.1;
          // The state that has changed here is the animation object’s value.
        });
      });
    _animation.addStatusListener((status) {
      if (_currentIndex<_words.length-1){
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
          _currentIndex++;
          _angle = 0.0;
          _radius =0.0;
        }
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
    _mediaQueryData = MediaQuery.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double x = _radius * cos(_angle);
                double y = _radius * sin(_angle);
                double size = sqrt(pow(x, 2) + pow(y, 2));

                // Calculate the speed based on the distance
                return Positioned(

                  left: (_mediaQueryData.size.width / 2) + x,
                  top: (_mediaQueryData.size.height / 2) + y,
                  child: Text(
                      _words[_currentIndex],
                      style: TextStyle(
                        fontSize: 20+size,
                        color: Colors.blue,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                      ),
                  )
                );
              }
            )
        ],
      ),
    );
  }
}
