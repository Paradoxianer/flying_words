import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/style/responsive_screen.dart';

void main() {
  testWidgets(
      'adds extra bottom padding matching the system navigation bar inset '
      '(#102 - the back button used to be hidden behind it)', (tester) async {
    const screenHeight = 800.0;

    Widget build(EdgeInsets viewPadding) => MediaQuery(
          data: MediaQueryData(
            size: const Size(400, screenHeight),
            viewPadding: viewPadding,
          ),
          child: MaterialApp(
            home: ResponsiveScreen(
              squarishMainArea: const SizedBox.shrink(),
              rectangularMenuArea:
                  Container(key: const Key('menu'), height: 10),
            ),
          ),
        );

    await tester.pumpWidget(build(EdgeInsets.zero));
    final noBarBottom =
        tester.getBottomLeft(find.byKey(const Key('menu'))).dy;

    // Simulates an on-screen Android navigation bar reserving 48px.
    await tester.pumpWidget(build(const EdgeInsets.only(bottom: 48)));
    final withBarBottom =
        tester.getBottomLeft(find.byKey(const Key('menu'))).dy;

    // The menu area must sit at least the nav bar's height further away
    // from the physical bottom edge than it does with no nav bar at all.
    expect(noBarBottom - withBarBottom, greaterThanOrEqualTo(47));
  });
}
