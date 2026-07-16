// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../currency/gold_ink.dart';
import '../jokers/joker_inventory.dart';
import '../jokers/joker_type.dart';
import '../jokers/joker_type_info.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';

/// Spend Goldtinte on Jokers (#54 Phase D) - the sink that gives the
/// currency earned in the "Verse" and "Herausforderungen" tabs a purpose.
class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context) {
    final goldInk = context.watch<GoldInkController>();
    final inventory = context.watch<JokerInventoryController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      children: [
        for (final type in JokerType.values) ...[
          _ShopItem(
            type: type,
            owned: inventory.countOf(type),
            canAfford: goldInk.balance >= jokerPriceInGoldInk,
            onBuy: () {
              final spent = context
                  .read<GoldInkController>()
                  .spend(jokerPriceInGoldInk);
              if (spent) {
                context.read<JokerInventoryController>().add(type);
              }
            },
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ShopItem extends StatelessWidget {
  final JokerType type;
  final int owned;
  final bool canAfford;
  final VoidCallback onBuy;

  const _ShopItem({
    required this.type,
    required this.owned,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.parchmentLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: palette.inkFullOpacity.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.parchmentDark,
              border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
            ),
            child: Icon(jokerIcon(type), color: palette.ink, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jokerName(l10n, type),
                  style: ScriptoriumText.label.copyWith(color: palette.gold),
                ),
                const SizedBox(height: 2),
                Text(
                  jokerDescription(l10n, type),
                  style: ScriptoriumText.body
                      .copyWith(fontSize: 13, color: palette.inkFaded),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.shopOwnedCount(owned),
                  style: ScriptoriumText.body
                      .copyWith(fontSize: 12, color: palette.inkFaded),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: canAfford ? onBuy : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.shopBuy),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 12),
                    const SizedBox(width: 3),
                    Text('$jokerPriceInGoldInk'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
