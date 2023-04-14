import 'dart:math';
import 'package:flutter/material.dart';

class Spiral extends StatefulWidget {
  final String text;
  final double speed;

  Spiral({required this.text, this.speed = 100.0});

  @override
  _SpiralState createState() => _SpiralState();
}

class _SpiralState extends State<Spiral> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Widget> _textWidgets;
  late double _radius;
  late double _angle;
  late int _currentIndex;

  late MediaQueryData _mediaQueryData;

  @override
  void initState() {
    super.initState();

    _textWidgets = [];
    _radius = 20.0;
    _angle = 0.0;
    _currentIndex = 0;

    // Calculate the duration based on the speed
    double distance = _mediaQueryData.size.width / 2 - 50;
    double durationInSeconds = distance / widget.speed;
    Duration duration = Duration(seconds: durationInSeconds.toInt());

    // Create a new animation controller with the calculated duration
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    // Add a listener to the animation controller to update the UI
    _controller.addListener(() {
      setState(() {
        _angle += 0.05;
        _radius += 2.0;
        _currentIndex = (_currentIndex + 1) % widget.text.split(" ").length;
      });
    });

    // Start the animation controller
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    List<String> words = widget.text.split(" ");

    // Generate a list of text widgets with decreasing font sizes
    _textWidgets = List.generate(
      words.length,
          (index) => Text(
        words[index],
        style: TextStyle(
          fontSize: 20.0 - (index * 2),
          color: Colors.black,
        ),
      ),
    );

    return Container(
      child: Stack(
        children: _textWidgets.map((textWidget) {
          // Calculate the x and y position of the text widget
          double x = _radius * cos(_angle);
          double y = _radius * sin(_angle);

          // Calculate the speed based on the distance
          double distance = sqrt(pow(x, 2) + pow(y, 2));
          double speed = distance / (_controller.duration!.inSeconds.toDouble());

          // Increment the angle for the next text widget
          _angle += (2 * pi) / _textWidgets.length;

          return Positioned(
            left: (_mediaQueryData.size.width / 2) + x - 25,
            top: (_mediaQueryData.size.height / 2) + y - 12.5,
            child: textWidget,
          );
        }).toList(),
      ),
    );
  }
}
