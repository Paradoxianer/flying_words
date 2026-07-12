import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';

/// A locked verse in the level selection: a wax-sealed page. The player
/// knows there is more to come but cannot open it yet (#52). The verse
/// right after the unlocked ones explains how to open the next page.
class SealedVerseCard extends StatelessWidget {
  final bool isNext;

  const SealedVerseCard({super.key, this.isNext = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: palette.parchmentDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.inkFaded.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Image.asset(
              'assets/images/padlock.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                isNext ? l10n.sealedHint : l10n.sealed,
                style: ScriptoriumText.verse.copyWith(color: palette.inkFaded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
