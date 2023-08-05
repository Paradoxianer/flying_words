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
                  child: Opacity(
                  opacity: 0.5,
                  child: IconButton(
                    icon: difficultyImagePath[e]!,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                onPressed: () {
                  final audioController = context.read<AudioController>();
                  audioController.playSfx(SfxType.buttonTap);
                GoRouter.of(context)
                    .go('/play/session/${level.number}');
              }
            ))))
                .toList(),
          ),
        ],
        )
    );
  }
}