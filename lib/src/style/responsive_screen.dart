// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A widget that makes it easy to create a screen with a square-ish
/// main area, a smaller menu area below it, and a small area for a message
/// on top.
///
/// Used to split into a side-by-side layout in landscape/wide windows, but
/// every one of our screens puts a scrollable list (or similarly
/// full-width content) in [squarishMainArea] and just a button or two in
/// [rectangularMenuArea] - the split squeezed the list into a narrow
/// column and stranded the menu area off to the side instead of below it
/// (#95). Always stacking vertically, like the portrait layout, fixes that
/// and works fine regardless of orientation since the content scrolls.
///
/// On wide windows the whole column is capped at [maxContentWidth] and
/// centered - full-width buttons/cards stretched across a 1600px desktop
/// window looked stretched and out of place (#95 follow-up).
class ResponsiveScreen extends StatelessWidget {
  /// This is the "hero" of the screen: the main, scrollable content.
  final Widget squarishMainArea;

  /// The menu area below [squarishMainArea] - usually a button or a row of
  /// buttons.
  final Widget rectangularMenuArea;

  /// An area reserved for some static text close to the top of the screen.
  final Widget topMessageArea;

  /// How much bigger should the [squarishMainArea] be compared to the other
  /// elements.
  final double mainAreaProminence;

  /// Caps how wide the whole screen gets on desktop-sized windows; the
  /// column is centered within this width instead of stretching edge to
  /// edge (#95).
  final double maxContentWidth;

  const ResponsiveScreen({
    required this.squarishMainArea,
    required this.rectangularMenuArea,
    this.topMessageArea = const SizedBox.shrink(),
    this.mainAreaProminence = 0.8,
    this.maxContentWidth = 700,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final padding = EdgeInsets.all(size.shortestSide / 30);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: padding,
                    child: topMessageArea,
                  ),
                ),
                Expanded(
                  flex: (mainAreaProminence * 100).round(),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    minimum: padding,
                    child: squarishMainArea,
                  ),
                ),
                Padding(
                  // Add MediaQuery.viewPadding.bottom explicitly (#102)
                  // rather than relying on SafeArea's own bottom inset:
                  // with SystemUiMode.edgeToEdge, some Android versions/nav
                  // bar styles under-report MediaQuery.padding.bottom (the
                  // value SafeArea uses) even though viewPadding.bottom -
                  // the raw system-bar inset, unaffected by that mismatch -
                  // is correct, which left the back button hidden behind
                  // the on-screen navigation bar.
                  padding: padding.copyWith(
                    bottom:
                        padding.bottom + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: rectangularMenuArea,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
