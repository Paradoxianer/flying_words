import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/input_device.dart';

void main() {
  setUp(InputDevice.reset);
  tearDown(InputDevice.reset);

  test('touch input keeps the normal flight time', () {
    InputDevice.register(PointerDeviceKind.touch);
    expect(InputDevice.usesMouse, isFalse);
    expect(InputDevice.timeFactor, 1.0);
  });

  test('mouse and trackpad get more flight time', () {
    InputDevice.register(PointerDeviceKind.mouse);
    expect(InputDevice.usesMouse, isTrue);
    expect(InputDevice.timeFactor, greaterThan(1.3));

    InputDevice.register(PointerDeviceKind.trackpad);
    expect(InputDevice.usesMouse, isTrue);
  });

  test('switching back to touch removes the compensation', () {
    InputDevice.register(PointerDeviceKind.mouse);
    InputDevice.register(PointerDeviceKind.touch);
    expect(InputDevice.timeFactor, 1.0);
  });
}
