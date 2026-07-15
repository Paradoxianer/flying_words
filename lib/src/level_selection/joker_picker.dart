// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../jokers/joker_inventory.dart';
import '../jokers/joker_type.dart';
import '../style/palette.dart';

/// Lets the player pick which Jokers (#53) to bring into the next round,
/// right here in the level selection - before the round starts, since
/// there is no time to activate them once the words start flying. Laid
/// out as a single, evenly spaced row at the end of the [LevelItem] card.
class JokerPicker extends StatelessWidget {
  final Set<JokerType> selected;
  final ValueChanged<JokerType> onToggle;

  const JokerPicker({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<JokerInventoryController>(
      builder: (context, inventory, child) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final type in JokerType.values)
            _JokerToggle(
              type: type,
              owned: inventory.countOf(type),
              isSelected: selected.contains(type),
              onTap: () => onToggle(type),
            ),
        ],
      ),
    );
  }
}

String _nameOf(AppLocalizations l10n, JokerType type) {
  switch (type) {
    case JokerType.sanduhr:
      return l10n.jokerSanduhrName;
    case JokerType.vergebung:
      return l10n.jokerVergebungName;
    case JokerType.klarheit:
      return l10n.jokerKlarheitName;
    case JokerType.bonuszeit:
      return l10n.jokerBonuszeitName;
  }
}

String _descriptionOf(AppLocalizations l10n, JokerType type) {
  switch (type) {
    case JokerType.sanduhr:
      return l10n.jokerSanduhrDescription;
    case JokerType.vergebung:
      return l10n.jokerVergebungDescription;
    case JokerType.klarheit:
      return l10n.jokerKlarheitDescription;
    case JokerType.bonuszeit:
      return l10n.jokerBonuszeitDescription;
  }
}

IconData _iconOf(JokerType type) {
  switch (type) {
    case JokerType.sanduhr:
      return Icons.hourglass_bottom;
    case JokerType.vergebung:
      return Icons.favorite;
    case JokerType.klarheit:
      return Icons.cleaning_services;
    case JokerType.bonuszeit:
      return Icons.timer_outlined;
  }
}

class _JokerToggle extends StatelessWidget {
  final JokerType type;
  final int owned;
  final bool isSelected;
  final VoidCallback onTap;

  const _JokerToggle({
    required this.type,
    required this.owned,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;
    final enabled = owned > 0;
    return Tooltip(
      message: '${_nameOf(l10n, type)}: ${_descriptionOf(l10n, type)}',
      child: InkResponse(
        onTap: enabled ? onTap : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? palette.gold.withValues(alpha: 0.35)
                    : enabled
                        ? palette.parchmentDark
                        : palette.parchmentDark.withValues(alpha: 0.4),
                border: Border.all(
                  color: isSelected ? palette.gold : palette.gold.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                _iconOf(type),
                color: enabled ? palette.ink : palette.inkFaded,
                size: 18,
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
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: palette.parchmentLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
