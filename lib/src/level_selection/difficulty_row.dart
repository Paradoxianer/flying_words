import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';


class DifficultyRow extends StatelessWidget {
  final level;
  DifficultyRow(this.level);

  Widget build(BuildContext context) {
    return Expanded(
        child: Stack(
      children: <Widget>[
        Expanded(
        child: Text(level.text,
        softWrap: true)),
        Row(
            children: Difficulty.values
                .map<Widget>((e) =>
                Expanded(
                  child: ElevatedButton(
                onPressed: () {
                  final audioController = context.read<AudioController>();
                  audioController.playSfx(SfxType.buttonTap);
                GoRouter.of(context)
                    .go('/play/session/${level.number}');
              },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.black,
                      side: const BorderSide(
                        width: 1.0,
                        color: Colors.green,
                      )),
                  child: Text(e.name),
            )))
                .toList(),
          ),
        ],
        )
    );
  }
}