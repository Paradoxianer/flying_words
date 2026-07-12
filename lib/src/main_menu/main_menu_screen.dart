// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/games_services.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final gamesServicesController = context.watch<GamesServicesController?>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();
    final l10n = AppLocalizations.of(context)!;

    // Always a single centered, stacked column - unlike most other screens,
    // the main menu is short enough that ResponsiveScreen's landscape split
    // (title on the left, buttons pinned to the bottom-right) just leaves
    // most of a wide/16:9 window empty instead of helping (#69).
    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: -0.06,
                    child: Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: ScriptoriumText.display
                          .copyWith(color: palette.inkFullOpacity),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // A golden rule line, like an illuminated manuscript.
                  Container(
                    width: 140,
                    height: 2,
                    color: palette.gold,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.mainMenuTagline,
                    textAlign: TextAlign.center,
                    style:
                        ScriptoriumText.verse.copyWith(color: palette.inkFaded),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).go('/play');
                    },
                    child: Text(l10n.play),
                  ),
                  _gap,
                  if (gamesServicesController != null) ...[
                    _hideUntilReady(
                      ready: gamesServicesController.signedIn,
                      child: ElevatedButton(
                        onPressed: () =>
                            gamesServicesController.showAchievements(),
                        child: Text(l10n.achievements),
                      ),
                    ),
                    _gap,
                  ],
                  // The device-local leaderboard needs no account, so it's
                  // always available - unlike Play Games/Game Center's
                  // online one, which is a later step (#14 "Stufe 2").
                  ElevatedButton(
                    onPressed: () => GoRouter.of(context).push('/leaderboard'),
                    child: Text(l10n.leaderboard),
                  ),
                  _gap,
                  ElevatedButton(
                    onPressed: () => GoRouter.of(context).push('/settings'),
                    child: Text(l10n.settings),
                  ),
                  _gap,
                  ElevatedButton(
                    onPressed: () => GoRouter.of(context).push('/help'),
                    child: Text(l10n.help),
                  ),
                  _gap,
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: settingsController.muted,
                      builder: (context, muted, child) {
                        return IconButton(
                          onPressed: () => settingsController.toggleMuted(),
                          icon:
                              Icon(muted ? Icons.volume_off : Icons.volume_up),
                        );
                      },
                    ),
                  ),
                  _gap,
                  Text(
                    l10n.musicAttribution,
                    style: ScriptoriumText.verse
                        .copyWith(fontSize: 13, color: palette.inkFaded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Prevents the game from showing game-services-related menu items
  /// until we're sure the player is signed in.
  ///
  /// This normally happens immediately after game start, so players will not
  /// see any flash. The exception is folks who decline to use Game Center
  /// or Google Play Game Services, or who haven't yet set it up.
  Widget _hideUntilReady({required Widget child, required Future<bool> ready}) {
    return FutureBuilder<bool>(
      future: ready,
      builder: (context, snapshot) {
        // Use Visibility here so that we have the space for the buttons
        // ready.
        return Visibility(
          visible: snapshot.data ?? false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          child: child,
        );
      },
    );
  }

  static const _gap = SizedBox(height: 10);
}
