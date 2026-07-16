// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// How many rewarded ads the player has watched today, per reward category
/// (#54 Phase D addendum: "Rewarded Ads" in the shop). The date is stored
/// as a `yyyy-MM-dd` string, same convention as [ChallengesData], so it
/// compares and persists without timezone ambiguity.
class RewardedAdLimitData {
  final String? date;
  final int jokerAdsWatched;
  final int goldInkAdsWatched;

  const RewardedAdLimitData({
    this.date,
    this.jokerAdsWatched = 0,
    this.goldInkAdsWatched = 0,
  });

  RewardedAdLimitData copyWith({
    String? date,
    int? jokerAdsWatched,
    int? goldInkAdsWatched,
  }) =>
      RewardedAdLimitData(
        date: date ?? this.date,
        jokerAdsWatched: jokerAdsWatched ?? this.jokerAdsWatched,
        goldInkAdsWatched: goldInkAdsWatched ?? this.goldInkAdsWatched,
      );

  factory RewardedAdLimitData.fromJson(Map<String, dynamic> json) =>
      RewardedAdLimitData(
        date: json['date'] as String?,
        jokerAdsWatched: json['jokerAdsWatched'] as int? ?? 0,
        goldInkAdsWatched: json['goldInkAdsWatched'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (date != null) 'date': date,
        'jokerAdsWatched': jokerAdsWatched,
        'goldInkAdsWatched': goldInkAdsWatched,
      };
}
