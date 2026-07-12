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
import 'legal_section.dart';

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({super.key});

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
              l10n.impressum,
              textAlign: TextAlign.center,
              style:
                  ScriptoriumText.display.copyWith(color: palette.inkFullOpacity),
            ),
            _gap,
            LegalSection(
              title: l10n.impressumProviderTitle,
              body: l10n.impressumProviderBody,
              palette: palette,
            ),
            LegalSection(
              title: l10n.impressumContactTitle,
              body: l10n.impressumContactBody,
              palette: palette,
            ),
            LegalSection(
              title: l10n.impressumResponsibleTitle,
              body: l10n.impressumResponsibleBody,
              palette: palette,
            ),
            LegalSection(
              title: l10n.impressumDisputeTitle,
              body: l10n.impressumDisputeBody,
              palette: palette,
            ),
            LegalSection(
              title: l10n.impressumLiabilityTitle,
              body: l10n.impressumLiabilityBody,
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
