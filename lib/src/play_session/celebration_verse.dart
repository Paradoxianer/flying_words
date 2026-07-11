import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import '../style/scriptorium_text.dart';

/// After a win the verse assembles itself: the words glide in from the
/// outside, staggered in verse order, and settle into a readable, centered
/// text with the missed words marked in sealing-wax red (#55).
class CelebrationVerse extends StatelessWidget {
  final List<String> words;
  final Set<int> errors;

  const CelebrationVerse({
    super.key,
    required this.words,
    required this.errors,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final wordCount = max(words.length, 1);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 600 + 90 * wordCount),
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
    // Staggered per-word progress: word i animates within the window
    // [i, i+3] of the overall timeline (measured in word slots), so the
    // verse writes itself word by word.
    final slots = wordCount + 3;
    final progress = Curves.easeOutCubic
        .transform(((t * slots - index) / 3).clamp(0.0, 1.0));
    // Each word flies in from its own direction outside the text.
    final angle = index * 2 * pi / wordCount;
    final offset = Offset(cos(angle), sin(angle)) * 140 * (1 - progress);
    return Opacity(
      opacity: progress,
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
