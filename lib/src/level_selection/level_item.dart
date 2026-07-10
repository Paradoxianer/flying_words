import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';

class LevelItem extends StatelessWidget {
  final Lesson level;
  const LevelItem(this.level, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              level.verse,
              style: const TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              level.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final difficulty in Difficulty.values)
                  IconButton(
                    tooltip: difficulty.name,
                    onPressed: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context)
                          .go('/play/session/${level.number}/${difficulty.name}');
                    },
                    icon: Image.asset(
                      difficultyImagePath[difficulty]!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
