import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';

class LevelItem extends StatelessWidget {
  final level;
  LevelItem(this.level);

  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
            level.verse,
            textAlign: TextAlign.center
        ),
        subtitle:
         Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Expanded(
                child: Text(
              level.text,
              softWrap: true,
           //   style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            )),
            Row(
              children: Difficulty.values
                  .map<Widget>((e) => Expanded(
                      child: Opacity(
                          opacity: 0.5,
                          child: IconButton(
                              icon: difficultyImagePath[e]!,
                              padding: EdgeInsets.zero,
                              //constraints: BoxConstraints(),
                              onPressed: () {
                                final audioController =
                                    context.read<AudioController>();
                                audioController.playSfx(SfxType.buttonTap);
                                GoRouter.of(context)
                                    .go('/play/session/${level.number}/${e.name}');
                              }))))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
