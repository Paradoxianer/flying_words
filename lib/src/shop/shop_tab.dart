// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../ads/ads_controller.dart';
import '../ads/rewarded_ad_limit_controller.dart';
import '../currency/gold_ink.dart';
import '../jokers/joker_inventory.dart';
import '../jokers/joker_type.dart';
import '../jokers/joker_type_info.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';
import '../style/snack_bar.dart';

/// Spend Goldtinte on Jokers (#54 Phase D) - the sink that gives the
/// currency earned in the "Verse" and "Herausforderungen" tabs a purpose.
/// Optionally, watching a rewarded ad is a free alternative path to a
/// Joker or to some Goldtinte (#54 Phase D addendum) - only shown once
/// ads are actually available ([AdsController] is mobile-only, #17).
class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context) {
    final goldInk = context.watch<GoldInkController>();
    final inventory = context.watch<JokerInventoryController>();
    final adsController = context.watch<AdsController?>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      children: [
        if (adsController != null) ...[
          const _EarnGoldInkCard(),
          const SizedBox(height: 10),
        ],
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

/// Watching an ad here grants some Goldtinte for free, not tied to any
/// specific Joker - shown above the Joker cards since it isn't one of them.
class _EarnGoldInkCard extends StatefulWidget {
  const _EarnGoldInkCard();

  @override
  State<_EarnGoldInkCard> createState() => _EarnGoldInkCardState();
}

class _EarnGoldInkCardState extends State<_EarnGoldInkCard> {
  bool _loading = false;

  Future<void> _watchAd() async {
    setState(() => _loading = true);
    final earned =
        await context.read<AdsController>().showRewardedAd();
    if (!mounted) return;
    setState(() => _loading = false);
    if (earned) {
      context.read<GoldInkController>().earn(goldInkRewardedAdAmount);
      unawaited(
          context.read<RewardedAdLimitController>().recordGoldInkAdWatched());
    } else {
      showSnackBar(AppLocalizations.of(context)!.shopAdFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final limits = context.watch<RewardedAdLimitController>();
    final remaining = rewardedAdDailyLimit - limits.goldInkAdsWatchedToday();
    final canWatch = !_loading && limits.canWatchGoldInkAd();

    return _ShopCard(
      icon: Icons.play_circle_outline,
      title: l10n.shopEarnGoldInkTitle,
      description:
          l10n.shopEarnGoldInkDescription(goldInkRewardedAdAmount),
      caption: l10n.shopWatchAdRemaining(
          remaining.clamp(0, rewardedAdDailyLimit), rewardedAdDailyLimit),
      trailing: FilledButton(
        onPressed: canWatch ? _watchAd : null,
        child: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.shopWatchAd),
      ),
    );
  }
}

class _ShopItem extends StatefulWidget {
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
  State<_ShopItem> createState() => _ShopItemState();
}

class _ShopItemState extends State<_ShopItem> {
  bool _loading = false;

  Future<void> _watchAd() async {
    setState(() => _loading = true);
    final earned =
        await context.read<AdsController>().showRewardedAd();
    if (!mounted) return;
    setState(() => _loading = false);
    if (earned) {
      context.read<JokerInventoryController>().add(widget.type);
      unawaited(
          context.read<RewardedAdLimitController>().recordJokerAdWatched());
    } else {
      showSnackBar(AppLocalizations.of(context)!.shopAdFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final adsController = context.watch<AdsController?>();

    return _ShopCard(
      icon: jokerIcon(widget.type),
      title: jokerName(l10n, widget.type),
      description: jokerDescription(l10n, widget.type),
      caption: l10n.shopOwnedCount(widget.owned),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: widget.canAfford ? widget.onBuy : null,
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
          if (adsController != null) ...[
            const SizedBox(height: 6),
            _WatchAdLink(loading: _loading, onWatch: _watchAd),
          ],
        ],
      ),
    );
  }
}

/// The small "Werbung ansehen" text-button under a Joker's "Kaufen" button,
/// its own widget only so it can read [RewardedAdLimitController] and
/// rebuild on its own without the whole [_ShopItem] doing so.
class _WatchAdLink extends StatelessWidget {
  final bool loading;
  final VoidCallback onWatch;

  const _WatchAdLink({required this.loading, required this.onWatch});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.watch<Palette>();
    final limits = context.watch<RewardedAdLimitController>();
    final canWatch = !loading && limits.canWatchJokerAd();

    return TextButton(
      onPressed: canWatch ? onWatch : null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: loading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              l10n.shopWatchAd,
              style: ScriptoriumText.body
                  .copyWith(fontSize: 11, color: palette.gold),
            ),
    );
  }
}

/// The shared card chrome for both a Joker item and the Goldtinte-ad card.
class _ShopCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String caption;
  final Widget trailing;

  const _ShopCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.caption,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

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
            child: Icon(icon, color: palette.ink, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ScriptoriumText.label.copyWith(color: palette.gold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: ScriptoriumText.body
                      .copyWith(fontSize: 13, color: palette.inkFaded),
                ),
                const SizedBox(height: 4),
                Text(
                  caption,
                  style: ScriptoriumText.body
                      .copyWith(fontSize: 12, color: palette.inkFaded),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
