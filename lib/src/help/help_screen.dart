// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import '../style/scriptorium_text.dart';
import '../style/responsive_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _gap = SizedBox(height: 24);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            const SizedBox(height: 40),
            Text(
              'Hilfe',
              textAlign: TextAlign.center,
              style:
                  ScriptoriumText.display.copyWith(color: palette.inkFullOpacity),
            ),
            _gap,
            _Section(
              title: 'So wird gespielt',
              body: 'Ein Bibelvers wird dir Wort für Wort vorgestellt. '
                  'Danach fliegen mehrere Wörter über den Bildschirm — tippe '
                  'immer auf das nächste richtige Wort des Verses, um ihn '
                  'Stück für Stück auswendig zu lernen.',
              palette: palette,
            ),
            _Section(
              title: 'Die Siegel I, II, III',
              body: 'Jeder Vers hat drei Schwierigkeitsstufen: Siegel I '
                  '(Bronze, langsam), Siegel II (Silber, schneller) und '
                  'Siegel III (Gold, sehr schnell). Siegel II schaltet sich '
                  'frei, sobald du in Siegel I mindestens 2 Sterne erreicht '
                  'hast — Siegel III entsprechend nach 2 Sternen in Siegel II.',
              palette: palette,
            ),
            _Section(
              title: 'Sterne',
              body: 'In Siegel I und II gibt es bis zu 3 Sterne: 3 Sterne für '
                  'einen fehlerfreien Lauf, 2 Sterne für höchstens 2 Fehler, '
                  'sonst 1 Stern fürs Schaffen. Siegel III bringt bei '
                  'Erfolg einen einzelnen Meisterstern.',
              palette: palette,
            ),
            _Section(
              title: 'Das Auge — blind spielen',
              body: 'Über dem Vers kannst du mit dem Augensymbol den Text '
                  'verbergen und ganz aus dem Gedächtnis spielen. Ein '
                  'erfolgreicher blinder Lauf bringt 50 % mehr Punkte.',
              palette: palette,
            ),
            _Section(
              title: 'Eigene Verse',
              body: 'Hast du alle vorgegebenen Verse in Siegel I geschafft, '
                  'kannst du dir eigene Bibelstellen hinzufügen und ebenso '
                  'spielend auswendig lernen.',
              palette: palette,
            ),
            _gap,
          ],
        ),
        rectangularMenuArea: FilledButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          child: const Text('Zurück'),
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
