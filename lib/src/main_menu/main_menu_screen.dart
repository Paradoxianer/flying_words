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
import '../legal/consent_controller.dart';
import '../legal/privacy_policy_content.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _maybeShowPrivacyNotice());
  }

  /// Presents the privacy notice once, on first app start (#111) - blocking
  /// (no barrier dismiss, no back-button dismiss) since acknowledging it is
  /// the whole point, but never gates playing itself.
  ///
  /// This is a notice, not an opt-in/opt-out consent gate: the only data
  /// processed before any explicit choice is the locally-stored game
  /// progress, which is necessary for the app to function. Ads and game
  /// services each have their own separate consent/sign-in flow at the
  /// point they're actually enabled, so there is nothing here to decline.
  /// The body reuses [PrivacyPolicyContent], the same text shown under
  /// Settings, so the legal wording only lives in one place.
  Future<void> _maybeShowPrivacyNotice() async {
    final consent = context.read<ConsentController>();
    await consent.getLatestFromStore();
    if (!mounted || consent.privacyNoticeSeen) return;
    final l10n = AppLocalizations.of(context)!;
    final palette = context.read<Palette>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l10n.privacyNoticeTitle),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(dialogContext).size.height * 0.6,
            child: SingleChildScrollView(
              child: PrivacyPolicyContent(palette: palette),
            ),
          ),
          actions: [
            FilledButton(
              key: const Key('privacy-notice-accept'),
              onPressed: () {
                consent.markPrivacyNoticeSeen();
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.privacyNoticeAcceptButton),
            ),
          ],
        ),
      ),
    );
  }

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
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 96,
                    height: 96,
                  ),
                  const SizedBox(height: 8),
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
