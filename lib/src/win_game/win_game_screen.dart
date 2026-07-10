// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../game_internals/lesson.dart';
import '../game_internals/level_state.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../play_session/text_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatelessWidget {
  final Score score;
  final Lesson lesson;
  final LevelState levelState;

  const WinGameScreen({
    super.key,
    required this.score,
    required this.lesson,
    required this.levelState,
  });

  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();

    const gap = SizedBox(height: 10);

    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (adsControllerAvailable && !adsRemoved) ...[
              const Expanded(
                child: Center(
                  child: BannerAdWidget(),
                ),
              ),
            ],
            gap,
            const Center(
              child: Text(
                'Gewonnen!',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 50),
              ),
            ),
            gap,
            Center(
              child: Text(
                lesson.verse,
                style: const TextStyle(
                    fontFamily: 'Permanent Marker', fontSize: 24),
              ),
            ),
            gap,
            // The whole verse once more, with the missed words highlighted,
            // so the player sees what to practice.
            Flexible(
              child: SingleChildScrollView(
                child: TextProgress(lesson: lesson, state: levelState),
              ),
            ),
            gap,
            Center(
              child: Text(
                'Score: ${score.score}\n'
                'Fehler: ${levelState.numErrors}\n'
                'Zeit: ${score.formattedTime}',
                style: const TextStyle(
                    fontFamily: 'Permanent Marker', fontSize: 20),
              ),
            ),
          ],
        ),
        rectangularMenuArea: FilledButton(
          onPressed: () {
            GoRouter.of(context).go('/play');
          },
          child: const Text('Weiter'),
        ),
      ),
    );
  }
}
