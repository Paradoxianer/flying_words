// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../game_internals/level_state.dart';
import '../jokers/joker_inventory.dart';
import '../jokers/joker_type.dart';
import '../style/palette.dart';
import '../style/snack_bar.dart';

/// The Joker tray shown during play (#53): one button per [JokerType],
/// showing how many the player owns. Tapping spends one from the
/// inventory and triggers the matching effect on [LevelState].
class JokerTray extends StatelessWidget {
  const JokerTray({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<JokerInventoryController, LevelState>(
      builder: (context, inventory, levelState, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final type in JokerType.values)
            _JokerButton(
              type: type,
              owned: inventory.countOf(type),
              onUse: () => _use(context, inventory, levelState, type),
            ),
        ],
      ),
    );
  }

  void _use(BuildContext context, JokerInventoryController inventory,
      LevelState levelState, JokerType type) {
    final l10n = AppLocalizations.of(context)!;
    if (!inventory.use(type)) {
      showSnackBar(l10n.jokerNoneOwned(_nameOf(l10n, type)));
      return;
    }
    switch (type) {
      case JokerType.grace:
        levelState.useGrace();
        break;
      case JokerType.sanduhr:
        levelState.useSanduhr();
        break;
      case JokerType.tintenloescher:
        levelState.useTintenloescher();
        break;
      case JokerType.federkiel:
        levelState.useFederkiel();
        break;
    }
  }
}

String _nameOf(AppLocalizations l10n, JokerType type) {
  switch (type) {
    case JokerType.grace:
      return l10n.jokerGraceName;
    case JokerType.sanduhr:
      return l10n.jokerSanduhrName;
    case JokerType.tintenloescher:
      return l10n.jokerTintenloescherName;
    case JokerType.federkiel:
      return l10n.jokerFederkielName;
  }
}

String _descriptionOf(AppLocalizations l10n, JokerType type) {
  switch (type) {
    case JokerType.grace:
      return l10n.jokerGraceDescription;
    case JokerType.sanduhr:
      return l10n.jokerSanduhrDescription;
    case JokerType.tintenloescher:
      return l10n.jokerTintenloescherDescription;
    case JokerType.federkiel:
      return l10n.jokerFederkielDescription;
  }
}

IconData _iconOf(JokerType type) {
  switch (type) {
    case JokerType.grace:
      return Icons.favorite;
    case JokerType.sanduhr:
      return Icons.hourglass_bottom;
    case JokerType.tintenloescher:
      return Icons.auto_fix_high;
    case JokerType.federkiel:
      return Icons.edit;
  }
}

class _JokerButton extends StatelessWidget {
  final JokerType type;
  final int owned;
  final VoidCallback onUse;

  const _JokerButton({
    required this.type,
    required this.owned,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;
    final enabled = owned > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Tooltip(
        message: _descriptionOf(l10n, type),
        child: InkResponse(
          onTap: onUse,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enabled
                      ? palette.parchmentDark
                      : palette.parchmentDark.withValues(alpha: 0.4),
                  border: Border.all(color: palette.gold, width: 1.5),
                ),
                child: Icon(
                  _iconOf(type),
                  color: enabled ? palette.ink : palette.inkFaded,
                  size: 22,
                ),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: palette.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.jokerOwnedCount(owned),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: palette.parchmentLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
