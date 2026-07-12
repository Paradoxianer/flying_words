// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../ads/ads_controller.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'custom_name_dialog.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            _gap,
            Text(
              l10n.settings,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cormorant Garamond', fontWeight: FontWeight.w700,
                fontSize: 55,
                height: 1,
              ),
            ),
            _gap,
            _NameChangeLine(l10n.name),
            ValueListenableBuilder<bool>(
              valueListenable: settings.soundsOn,
              builder: (context, soundsOn, child) => _SettingsLine(
                l10n.soundEffects,
                Icon(soundsOn ? Icons.graphic_eq : Icons.volume_off),
                onSelected: () => settings.toggleSoundsOn(),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: settings.musicOn,
              builder: (context, musicOn, child) => _SettingsLine(
                l10n.music,
                Icon(musicOn ? Icons.music_note : Icons.music_off),
                onSelected: () => settings.toggleMusicOn(),
              ),
            ),
            ValueListenableBuilder<Locale>(
              valueListenable: settings.locale,
              builder: (context, locale, child) => _SettingsLine(
                l10n.language,
                Text(locale.languageCode == 'de' ? 'Deutsch' : 'English'),
                onSelected: () => settings.setLocale(
                  Locale(locale.languageCode == 'de' ? 'en' : 'de'),
                ),
              ),
            ),
            Consumer<InAppPurchaseController?>(
                builder: (context, inAppPurchase, child) {
              if (inAppPurchase == null) {
                // In-app purchases are not supported yet.
                // Go to lib/main.dart and uncomment the lines that create
                // the InAppPurchaseController.
                return const SizedBox.shrink();
              }

              Widget icon;
              VoidCallback? callback;
              if (inAppPurchase.adRemoval.active) {
                icon = const Icon(Icons.check);
              } else if (inAppPurchase.adRemoval.pending) {
                icon = const CircularProgressIndicator();
              } else {
                icon = const Icon(Icons.ad_units);
                callback = () {
                  inAppPurchase.buy();
                };
              }
              return _SettingsLine(
                l10n.removeAds,
                icon,
                onSelected: callback,
              );
            }),
            _SettingsLine(
              l10n.resetProgress,
              const Icon(Icons.delete),
              onSelected: () {
                context.read<PlayerProgress>().reset();

                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.progressResetConfirmation)),
                );
              },
            ),
            Consumer<AdsController?>(builder: (context, adsController, child) {
              if (adsController == null) {
                // Ads aren't enabled yet (#17); nothing to reopen.
                return const SizedBox.shrink();
              }
              return FutureBuilder<bool>(
                future: adsController.privacyOptionsRequired,
                builder: (context, snapshot) {
                  if (snapshot.data != true) return const SizedBox.shrink();
                  return _SettingsLine(
                    l10n.privacyOptions,
                    const Icon(Icons.privacy_tip_outlined),
                    onSelected: () => adsController.showPrivacyOptionsForm(),
                  );
                },
              );
            }),
            _SettingsLine(
              l10n.impressum,
              const Icon(Icons.description_outlined),
              onSelected: () => GoRouter.of(context).push('/impressum'),
            ),
            _SettingsLine(
              l10n.privacyPolicy,
              const Icon(Icons.policy_outlined),
              onSelected: () => GoRouter.of(context).push('/privacy'),
            ),
            _gap,
          ],
        ),
        rectangularMenuArea: FilledButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          child: Text(l10n.back),
        ),
      ),
    );
  }
}

class _NameChangeLine extends StatelessWidget {
  final String title;

  const _NameChangeLine(this.title);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: () => showCustomNameDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                  fontFamily: 'Cormorant Garamond', fontWeight: FontWeight.w700,
                  fontSize: 30,
                )),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: settings.playerName,
              builder: (context, name, child) => Text(
                '‘$name’',
                style: const TextStyle(
                  fontFamily: 'Cormorant Garamond', fontWeight: FontWeight.w700,
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsLine extends StatelessWidget {
  final String title;

  final Widget icon;

  final VoidCallback? onSelected;

  const _SettingsLine(this.title, this.icon, {this.onSelected});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: onSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cormorant Garamond', fontWeight: FontWeight.w700,
                  fontSize: 30,
                ),
              ),
            ),
            icon,
          ],
        ),
      ),
    );
  }
}
