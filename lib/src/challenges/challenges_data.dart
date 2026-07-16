// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../game_internals/lesson.dart';

/// Everything persisted for the daily/weekly challenges and the play streak
/// (#53 Phase C). Dates are stored as `yyyy-MM-dd` strings so they compare
/// and persist without any timezone ambiguity.
class ChallengesData {
  /// The date (`yyyy-MM-dd`) the current daily verse was rolled for.
  final String? dailyDate;

  /// The curated verse ([Lesson.number]) picked for [dailyDate].
  final int? dailyVerseNumber;

  final bool dailyClaimed;

  /// The Monday (`yyyy-MM-dd`) the current weekly goal was rolled for.
  final String? weekStart;

  /// The seal the weekly star goal applies to this week.
  final Difficulty? weeklyDifficulty;

  final int weeklyTarget;
  final int weeklyStars;
  final bool weeklyClaimed;

  /// The last date (`yyyy-MM-dd`) a run was won on, for streak tracking.
  final String? lastPlayedDate;

  final int streakDays;
  final bool streak3Claimed;
  final bool streak7Claimed;

  const ChallengesData({
    this.dailyDate,
    this.dailyVerseNumber,
    this.dailyClaimed = false,
    this.weekStart,
    this.weeklyDifficulty,
    this.weeklyTarget = 0,
    this.weeklyStars = 0,
    this.weeklyClaimed = false,
    this.lastPlayedDate,
    this.streakDays = 0,
    this.streak3Claimed = false,
    this.streak7Claimed = false,
  });

  ChallengesData copyWith({
    String? dailyDate,
    int? dailyVerseNumber,
    bool? dailyClaimed,
    String? weekStart,
    Difficulty? weeklyDifficulty,
    int? weeklyTarget,
    int? weeklyStars,
    bool? weeklyClaimed,
    String? lastPlayedDate,
    int? streakDays,
    bool? streak3Claimed,
    bool? streak7Claimed,
  }) =>
      ChallengesData(
        dailyDate: dailyDate ?? this.dailyDate,
        dailyVerseNumber: dailyVerseNumber ?? this.dailyVerseNumber,
        dailyClaimed: dailyClaimed ?? this.dailyClaimed,
        weekStart: weekStart ?? this.weekStart,
        weeklyDifficulty: weeklyDifficulty ?? this.weeklyDifficulty,
        weeklyTarget: weeklyTarget ?? this.weeklyTarget,
        weeklyStars: weeklyStars ?? this.weeklyStars,
        weeklyClaimed: weeklyClaimed ?? this.weeklyClaimed,
        lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
        streakDays: streakDays ?? this.streakDays,
        streak3Claimed: streak3Claimed ?? this.streak3Claimed,
        streak7Claimed: streak7Claimed ?? this.streak7Claimed,
      );

  factory ChallengesData.fromJson(Map<String, dynamic> json) => ChallengesData(
        dailyDate: json['dailyDate'] as String?,
        dailyVerseNumber: json['dailyVerseNumber'] as int?,
        dailyClaimed: json['dailyClaimed'] as bool? ?? false,
        weekStart: json['weekStart'] as String?,
        weeklyDifficulty: (json['weeklyDifficulty'] as String?) == null
            ? null
            : Difficulty.values.asNameMap()[json['weeklyDifficulty']],
        weeklyTarget: json['weeklyTarget'] as int? ?? 0,
        weeklyStars: json['weeklyStars'] as int? ?? 0,
        weeklyClaimed: json['weeklyClaimed'] as bool? ?? false,
        lastPlayedDate: json['lastPlayedDate'] as String?,
        streakDays: json['streakDays'] as int? ?? 0,
        streak3Claimed: json['streak3Claimed'] as bool? ?? false,
        streak7Claimed: json['streak7Claimed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        if (dailyDate != null) 'dailyDate': dailyDate,
        if (dailyVerseNumber != null) 'dailyVerseNumber': dailyVerseNumber,
        'dailyClaimed': dailyClaimed,
        if (weekStart != null) 'weekStart': weekStart,
        if (weeklyDifficulty != null)
          'weeklyDifficulty': weeklyDifficulty!.name,
        'weeklyTarget': weeklyTarget,
        'weeklyStars': weeklyStars,
        'weeklyClaimed': weeklyClaimed,
        if (lastPlayedDate != null) 'lastPlayedDate': lastPlayedDate,
        'streakDays': streakDays,
        'streak3Claimed': streak3Claimed,
        'streak7Claimed': streak7Claimed,
      };
}
