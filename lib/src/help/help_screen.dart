// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../game_internals/lesson.dart';
import '../jokers/joker_type.dart';
import '../jokers/joker_type_info.dart';
import '../level_selection/wax_seal.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';
import '../style/responsive_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _gap = SizedBox(height: 24);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.help,
              textAlign: TextAlign.center,
              style:
                  ScriptoriumText.display.copyWith(color: palette.inkFullOpacity),
            ),
            _gap,
            _Section(
              title: l10n.helpHowToPlayTitle,
              body: l10n.helpHowToPlayBody,
              palette: palette,
            ),
            _Section(
              title: l10n.helpSealsTitle,
              body: l10n.helpSealsBody,
              palette: palette,
              graphic: _SealsGraphic(palette: palette),
            ),
            _Section(
              title: l10n.helpStarsTitle,
              body: l10n.helpStarsBody,
              palette: palette,
              graphic: _StarsGraphic(palette: palette),
            ),
            _JokerSection(palette: palette, l10n: l10n),
            _Section(
              title: l10n.helpGoldInkTitle,
              body: l10n.helpGoldInkBody,
              palette: palette,
              graphic: Icon(Icons.auto_awesome, size: 22, color: palette.gold),
            ),
            _Section(
              title: l10n.helpBlindTitle,
              body: l10n.helpBlindBody,
              palette: palette,
              graphic: Icon(Icons.visibility, size: 22, color: palette.gold),
            ),
            _Section(
              title: l10n.helpOwnVersesTitle,
              body: l10n.helpOwnVersesBody,
              palette: palette,
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

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final Palette palette;

  /// A small illustrative icon/graphic shown next to the title (#104) -
  /// e.g. the wax seals, star icons, or the eye icon - so the concept
  /// being explained is recognizable, not just described in text.
  final Widget? graphic;

  const _Section({
    required this.title,
    required this.body,
    required this.palette,
    this.graphic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: ScriptoriumText.heading.copyWith(color: palette.gold),
                ),
              ),
              if (graphic != null) ...[
                const SizedBox(width: 10),
                graphic!,
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: ScriptoriumText.body.copyWith(color: palette.inkFullOpacity),
          ),
        ],
      ),
    );
  }
}

/// A small, static preview of the three wax seals (#104) - unlike [WaxSeal]
/// itself, this doesn't need real [VerseProgress] since it's purely
/// illustrative here.
class _SealsGraphic extends StatelessWidget {
  final Palette palette;

  const _SealsGraphic({required this.palette});

  Color _sealColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.slow:
        return palette.sealBronze;
      case Difficulty.normal:
        return palette.sealSilver;
      case Difficulty.insane:
        return palette.sealGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final difficulty in Difficulty.values)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _sealColor(difficulty),
              ),
              alignment: Alignment.center,
              child: Text(
                sealNumerals[difficulty]!,
                style: ScriptoriumText.heading
                    .copyWith(fontSize: 12, color: palette.trueWhite),
              ),
            ),
          ),
      ],
    );
  }
}

class _StarsGraphic extends StatelessWidget {
  final Palette palette;

  const _StarsGraphic({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(Icons.star, size: 20, color: palette.gold),
      ],
    );
  }
}

/// Explains the four Jokers (#53) with their icon, name and effect - not
/// covered anywhere else in the help screen before (#104).
class _JokerSection extends StatelessWidget {
  final Palette palette;
  final AppLocalizations l10n;

  const _JokerSection({required this.palette, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.helpJokerTitle,
            style: ScriptoriumText.heading.copyWith(color: palette.gold),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.helpJokerIntro,
            style: ScriptoriumText.body.copyWith(color: palette.inkFullOpacity),
          ),
          const SizedBox(height: 10),
          for (final type in JokerType.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(jokerIcon(type), size: 20, color: palette.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jokerName(l10n, type),
                          style: ScriptoriumText.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: palette.inkFullOpacity,
                          ),
                        ),
                        Text(
                          jokerDescription(l10n, type),
                          style: ScriptoriumText.body
                              .copyWith(fontSize: 13, color: palette.inkFaded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
