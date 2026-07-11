import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';
import 'wax_seal.dart';

/// One verse in the level selection: a parchment card with the verse,
/// the three wax seals (difficulties) and the earned stars.
class LevelItem extends StatelessWidget {
  final Lesson level;
  const LevelItem(this.level, {super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final progress =
        context.watch<PlayerProgress>().progressForVerse(level.verse);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: palette.parchmentLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: palette.inkFullOpacity.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              level.verse,
              style:
                  ScriptoriumText.verseRef.copyWith(color: palette.inkFullOpacity),
            ),
            const SizedBox(height: 4),
            Text(
              level.text,
              style: ScriptoriumText.verse
                  .copyWith(fontSize: 14, color: palette.inkFaded),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final difficulty in Difficulty.values)
                  WaxSeal(
                    key: Key('seal-${level.number}-${difficulty.name}'),
                    difficulty: difficulty,
                    progress: progress,
                    onPressed: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).go(
                          '/play/session/${level.number}/${difficulty.name}');
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
