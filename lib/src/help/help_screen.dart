// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
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
            ),
            _Section(
              title: l10n.helpStarsTitle,
              body: l10n.helpStarsBody,
              palette: palette,
            ),
            _Section(
              title: l10n.helpBlindTitle,
              body: l10n.helpBlindBody,
              palette: palette,
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

  const _Section({
    required this.title,
    required this.body,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ScriptoriumText.heading.copyWith(color: palette.gold),
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
