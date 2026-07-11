import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:provider/provider.dart';

import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';

const _sealNumerals = {
  Difficulty.slow: 'I',
  Difficulty.normal: 'II',
  Difficulty.insane: 'III',
};

/// A wax seal representing one difficulty of a verse: bronze, silver or
/// gold, with the earned stars underneath. Locked seals are greyed out
/// and carry the padlock (#26, #39).
class WaxSeal extends StatelessWidget {
  final Difficulty difficulty;
  final VerseProgress progress;
  final VoidCallback? onPressed;

  const WaxSeal({
    super.key,
    required this.difficulty,
    required this.progress,
    this.onPressed,
  });

  bool get unlocked => progress.unlocked(difficulty);

  Color _sealColor(Palette palette) {
    switch (difficulty) {
      case Difficulty.slow:
        return palette.sealBronze;
      case Difficulty.normal:
        return palette.sealSilver;
      case Difficulty.insane:
        return palette.sealGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final color = _sealColor(palette);
    final stars = progress.stars(difficulty);
    final maxStars = VerseProgress.maxStars(difficulty);

    final seal = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [
            Color.lerp(color, Colors.white, 0.45)!,
            color,
            Color.lerp(color, Colors.black, 0.25)!,
          ],
          stops: const [0.0, 0.65, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.inkFullOpacity.withValues(alpha: 0.35),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _sealNumerals[difficulty]!,
        style: ScriptoriumText.heading.copyWith(
          fontSize: 24,
          color: palette.trueWhite.withValues(alpha: 0.9),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: unlocked,
      label: 'Siegel ${_sealNumerals[difficulty]}'
          '${unlocked ? '' : ', gesperrt'}',
      child: InkWell(
        onTap: unlocked ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (unlocked)
                seal
              else
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(opacity: 0.35, child: seal),
                    Image.asset(
                      'assets/images/padlock.png',
                      key: Key('padlock-${difficulty.name}'),
                      width: 26,
                      height: 26,
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < maxStars; i++)
                    Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      key: i < stars ? Key('star-${difficulty.name}-$i') : null,
                      size: 15,
                      color: unlocked ? palette.gold : palette.inkFaded,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
