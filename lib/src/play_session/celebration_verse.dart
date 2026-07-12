import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import '../style/scriptorium_text.dart';

/// After a win the verse assembles itself: every word glides in from the
/// outside at once and settles into a readable, centered text with the
/// missed words marked in sealing-wax red (#55).
///
/// Words used to fly in staggered, one after another - readable, but slow
/// to finish on longer verses that players see over and over while
/// memorizing them (#69), so they now all arrive together instead.
class CelebrationVerse extends StatelessWidget {
  final List<String> words;
  final Set<int> errors;

  const CelebrationVerse({
    super.key,
    required this.words,
    required this.errors,
  });

  static const _duration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final wordCount = max(words.length, 1);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: _duration,
          curve: Curves.easeOutCubic,
          builder: (context, t, _) {
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                for (var i = 0; i < words.length; i++)
                  _word(palette, i, t, wordCount),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _word(Palette palette, int index, double t, int wordCount) {
    // Each word flies in from its own direction outside the text, all on
    // the same timeline t.
    final angle = index * 2 * pi / wordCount;
    final offset = Offset(cos(angle), sin(angle)) * 140 * (1 - t);
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: offset,
        child: Text(
          words[index],
          style: ScriptoriumText.verse.copyWith(
            fontSize: 22,
            color: errors.contains(index)
                ? palette.sealRed
                : palette.inkFullOpacity,
          ),
        ),
      ),
    );
  }
}
