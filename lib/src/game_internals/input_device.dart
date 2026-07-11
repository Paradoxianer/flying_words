import 'package:flutter/gestures.dart';

/// Tracks which kind of pointer the player is using, so the game can give
/// mouse and trackpad players more flight time (#57): moving a cursor to a
/// word takes longer than tapping it directly on a touch screen.
class InputDevice {
  static bool _usesMouse = false;

  static bool get usesMouse => _usesMouse;

  /// Multiplier on the word flight time for the current input device.
  static double get timeFactor => _usesMouse ? 1.45 : 1.0;

  static void register(PointerDeviceKind kind) {
    _usesMouse = kind == PointerDeviceKind.mouse ||
        kind == PointerDeviceKind.trackpad;
  }

  /// Only for tests.
  static void reset() {
    _usesMouse = false;
  }
}
