// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flying_words/src/level_selection/level_item.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'levels.dart';
import 'sealed_verse_card.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    final orderedVerses = [for (final level in gameLevels) level.verse];
    final unlockedCount = playerProgress.unlockedVerseCount(orderedVerses);

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Wähle deine Herausforderung',
                  style:
                      TextStyle(fontFamily: 'Cormorant Garamond', fontWeight: FontWeight.w700, fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: ListView(
                children: [
                  for (var i = 0; i < gameLevels.length; i++)
                    if (i < unlockedCount)
                      LevelItem(gameLevels[i])
                    else
                      // Locked verses stay visible as sealed cards so the
                      // player sees there is more to unlock (#52).
                      SealedVerseCard(
                        key: Key('sealed-${gameLevels[i].number}'),
                        // The very next verse hints at how to open it.
                        isNext: i == unlockedCount,
                      ),
                ],
              ),
            ),
          ],
        ),
        rectangularMenuArea: ElevatedButton(
          onPressed: () {
            GoRouter.of(context).go('/');
          },
          child: const Text('Zurück'),
        ),
      ),
    );
  }
}
