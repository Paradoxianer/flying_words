// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

// Uncomment the following lines when enabling Firebase Crashlytics
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/game_internals/level_state.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'l10n/gen/app_localizations.dart';

import 'src/ads/ads_controller.dart';
import 'src/ads/persistence/local_storage_rewarded_ad_limit_persistence.dart';
import 'src/ads/persistence/rewarded_ad_limit_persistence.dart';
import 'src/ads/rewarded_ad_limit_controller.dart';
import 'src/app_lifecycle/app_lifecycle.dart';
import 'src/audio/audio_controller.dart';
import 'src/challenges/challenges_controller.dart';
import 'src/challenges/persistence/challenges_persistence.dart';
import 'src/challenges/persistence/local_storage_challenges_persistence.dart';
import 'src/crashlytics/crashlytics.dart';
import 'src/currency/gold_ink.dart';
import 'src/currency/persistence/gold_ink_persistence.dart';
import 'src/currency/persistence/local_storage_gold_ink_persistence.dart';
import 'src/games_services/games_services.dart';
import 'src/games_services/score.dart';
import 'src/help/help_screen.dart';
import 'src/in_app_purchase/in_app_purchase.dart';
import 'src/jokers/joker_inventory.dart';
import 'src/jokers/joker_type.dart';
import 'src/jokers/persistence/joker_inventory_persistence.dart';
import 'src/jokers/persistence/local_storage_joker_inventory_persistence.dart';
import 'src/leaderboard/local_leaderboard_screen.dart';
import 'src/legal/consent_controller.dart';
import 'src/legal/impressum_screen.dart';
import 'src/legal/persistence/consent_persistence.dart';
import 'src/legal/persistence/local_storage_consent_persistence.dart';
import 'src/legal/privacy_screen.dart';
import 'src/level_selection/level_selection_screen.dart';
import 'src/level_selection/levels.dart';
import 'src/main_menu/main_menu_screen.dart';
import 'src/play_session/play_session_screen.dart';
import 'src/player_progress/persistence/local_storage_player_progress_persistence.dart';
import 'src/player_progress/persistence/player_progress_persistence.dart';
import 'src/player_progress/player_progress.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';
import 'src/settings/persistence/settings_persistence.dart';
import 'src/settings/settings.dart';
import 'src/settings/settings_screen.dart';
import 'src/style/my_transition.dart';
import 'src/style/palette.dart';
import 'src/style/scriptorium_text.dart';
import 'src/style/snack_bar.dart';
import 'src/verses/bolls_bible_api_client.dart';
import 'src/verses/custom_verses_controller.dart';
import 'src/verses/persistence/local_storage_custom_verses_persistence.dart';
import 'src/win_game/win_game_screen.dart';

Future<void> main() async {
  // To enable Firebase Crashlytics, uncomment the following lines and
  // the import statements at the top of this file.
  // See the 'Crashlytics' section of the main README.md file for details.

  FirebaseCrashlytics? crashlytics;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   try {
  //     WidgetsFlutterBinding.ensureInitialized();
  //     await Firebase.initializeApp(
  //       options: DefaultFirebaseOptions.currentPlatform,
  //     );
  //     crashlytics = FirebaseCrashlytics.instance;
  //   } catch (e) {
  //     debugPrint("Firebase couldn't be initialized: $e");
  //   }
  // }

  await guardWithCrashlytics(
    guardedMain,
    crashlytics: crashlytics,
  );
}

/// Without logging and crash reporting, this would be `void main()`.
void guardedMain() {
  if (kReleaseMode) {
    // Don't log anything below warnings in production.
    Logger.root.level = Level.WARNING;
  }
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: '
        '${record.loggerName}: '
        '${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  _log.info('Going full screen');
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // TODO: When ready, uncomment the following lines to enable integrations.
  //       Read the README for more info on each integration.

  AdsController? adsController;
  // Android-only for now (#17): iOS has no AdMob app/App ID configured yet
  // (ios/Runner/Info.plist is still missing GADApplicationIdentifier) -
  // the Google Mobile Ads SDK crashes on launch without it, so this must
  // stay Android-only until that's set up. Add `|| Platform.isIOS` back
  // once it is (same reasoning as the GamesServicesController guard below).
  if (!kIsWeb && Platform.isAndroid) {
    // Prepare the google_mobile_ads plugin so that the first ad loads
    // faster. This can be done later or with a delay if startup
    // experience suffers.
    //
    // Note (#17): still using AdMob's sample ad unit IDs on iOS (see
    // AdsController.preloadAd/showRewardedAd) until a real AdMob account
    // and unit IDs exist - swap those in before a real release build.
    adsController = AdsController(MobileAds.instance);
    adsController.initialize();
  }

  GamesServicesController? gamesServicesController;
  // Android-only for now (#14): Game Center isn't set up on the iOS side
  // yet, so signing in there would just fail. Add `|| Platform.isIOS` back
  // once that's done.
  if (!kIsWeb && Platform.isAndroid) {
    gamesServicesController = GamesServicesController()
      // Attempt to log the player in.
      ..initialize();
  }

  InAppPurchaseController? inAppPurchaseController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   inAppPurchaseController = InAppPurchaseController(InAppPurchase.instance)
  //     // Subscribing to [InAppPurchase.instance.purchaseStream] as soon
  //     // as possible in order not to miss any updates.
  //     ..subscribe();
  //   // Ask the store what the player has bought already.
  //   inAppPurchaseController.restorePurchases();
  // }

  final settingsPersistence = LocalStorageSettingsPersistence();
  final customVersesController = CustomVersesController(
    store: LocalStorageCustomVersesPersistence(),
    api: BollsBibleApiClient(),
  );

  // The curated verses' language follows the player's saved UI language,
  // falling back to the device's language (#2), so it must be known before
  // loading them. Load the curated verses from their JSON asset and the
  // player's own verses before starting the app, so the (synchronous)
  // router and level selection have them ready.
  settingsPersistence.getLanguageCode().then((languageCode) {
    final locale = resolveInitialLocale(languageCode);
    return Future.wait([
      loadCuratedVerses(locale: locale),
      customVersesController.loadFromStore(),
    ]);
  }).then((_) {
    runApp(
      MyApp(
        settingsPersistence: settingsPersistence,
        playerProgressPersistence: LocalStoragePlayerProgressPersistence(),
        goldInkPersistence: LocalStorageGoldInkPersistence(),
        jokerInventoryPersistence: LocalStorageJokerInventoryPersistence(),
        challengesPersistence: LocalStorageChallengesPersistence(),
        consentPersistence: LocalStorageConsentPersistence(),
        rewardedAdLimitPersistence: LocalStorageRewardedAdLimitPersistence(),
        inAppPurchaseController: inAppPurchaseController,
        adsController: adsController,
        gamesServicesController: gamesServicesController,
        customVersesController: customVersesController,
      ),
    );
  });
}

Logger _log = Logger('main.dart');

class MyApp extends StatelessWidget {
  static final _router = GoRouter(
    routes: [
      GoRoute(
          path: '/',
          builder: (context, state) =>
              const MainMenuScreen(key: Key('main menu')),
          routes: [
            GoRoute(
                path: 'play',
                pageBuilder: (context, state) => buildMyTransition<void>(
                      child: const LevelSelectionScreen(
                          key: Key('level selection')),
                      color: context.watch<Palette>().backgroundLevelSelection,
                    ),
                routes: [
                  GoRoute(
                    path: 'session/:level/:difficulty',
                    pageBuilder: (context, state) {
                      final levelNumber =
                          int.parse(state.pathParameters['level']!);
                      final Difficulty difficulty = Difficulty.values
                              .asNameMap()[state.pathParameters['difficulty']!] ??
                          Difficulty.slow;
                      // Look up the verse among the curated ones and the
                      // player's own custom verses.
                      final custom =
                          context.read<CustomVersesController>().verses;
                      final level = [...gameLevels, ...custom]
                          .singleWhere((e) => e.number == levelNumber);
                      final startBlind =
                          state.uri.queryParameters['blind'] == '1';
                      // Jokers chosen in the level selection before this
                      // round (#53).
                      final jokersParam = state.uri.queryParameters['jokers'];
                      final selectedJokers = jokersParam == null ||
                              jokersParam.isEmpty
                          ? const <JokerType>{}
                          : jokersParam
                              .split(',')
                              .map(JokerType.values.byName)
                              .toSet();
                      return buildMyTransition<void>(
                        child: PlaySessionScreen(
                          level,
                          difficulty,
                          key: const Key('play session'),
                          startBlind: startBlind,
                          selectedJokers: selectedJokers,
                        ),
                        color: context.watch<Palette>().backgroundPlaySession,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'won',
                    pageBuilder: (context, state) {
                      final map = state.extra! as Map<String, dynamic>;
                      final score = map['score'] as Score;
                      final levelState = map['levelState'] as LevelState;
                      final lesson = map['lesson'] as Lesson;
                      final difficulty = map['difficulty'] as Difficulty;
                      final previousBest = map['previousBest'] as Score?;
                      final goldInkEarned = map['goldInkEarned'] as int;
                      final earnedJokers =
                          map['earnedJokers'] as List<JokerType>? ?? const [];
                      // The celebration verse crossfades into the win
                      // screen instead of being pushed away (#55).
                      return CustomTransitionPage<void>(
                        transitionDuration: const Duration(milliseconds: 500),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                FadeTransition(opacity: animation, child: child),
                        child: WinGameScreen(
                          score: score,
                          key: const Key('win game'),
                          lesson: lesson,
                          levelState: levelState,
                          difficulty: difficulty,
                          previousBest: previousBest,
                          goldInkEarned: goldInkEarned,
                          earnedJokers: earnedJokers,
                        ),
                      );
                    },
                  )
                ]),
            GoRoute(
              path: 'settings',
              builder: (context, state) =>
                  const SettingsScreen(key: Key('settings')),
            ),
            GoRoute(
              path: 'help',
              builder: (context, state) =>
                  const HelpScreen(key: Key('help')),
            ),
            GoRoute(
              path: 'impressum',
              builder: (context, state) =>
                  const ImpressumScreen(key: Key('impressum')),
            ),
            GoRoute(
              path: 'privacy',
              builder: (context, state) =>
                  const PrivacyScreen(key: Key('privacy')),
            ),
            GoRoute(
              path: 'leaderboard',
              builder: (context, state) =>
                  const LocalLeaderboardScreen(key: Key('leaderboard')),
            ),
          ]),
    ],
  );

  final PlayerProgressPersistence playerProgressPersistence;

  final GoldInkPersistence goldInkPersistence;

  final JokerInventoryPersistence jokerInventoryPersistence;

  final ChallengesPersistence challengesPersistence;

  final ConsentPersistence consentPersistence;

  final RewardedAdLimitPersistence rewardedAdLimitPersistence;

  final SettingsPersistence settingsPersistence;

  final GamesServicesController? gamesServicesController;

  final InAppPurchaseController? inAppPurchaseController;

  final AdsController? adsController;

  final CustomVersesController customVersesController;

  const MyApp({
    required this.playerProgressPersistence,
    required this.goldInkPersistence,
    required this.jokerInventoryPersistence,
    required this.challengesPersistence,
    required this.consentPersistence,
    required this.rewardedAdLimitPersistence,
    required this.settingsPersistence,
    required this.inAppPurchaseController,
    required this.adsController,
    required this.gamesServicesController,
    required this.customVersesController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) {
              var progress = PlayerProgress(playerProgressPersistence);
              progress.getLatestFromStore(
                knownLessons: [...gameLevels, ...customVersesController.verses],
              );
              return progress;
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              final goldInk = GoldInkController(goldInkPersistence);
              goldInk.getLatestFromStore();
              return goldInk;
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              final jokers = JokerInventoryController(jokerInventoryPersistence);
              jokers.getLatestFromStore();
              return jokers;
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              final challenges = ChallengesController(challengesPersistence);
              challenges.getLatestFromStore();
              return challenges;
            },
          ),
          ChangeNotifierProvider(
            create: (context) => ConsentController(consentPersistence),
          ),
          ChangeNotifierProvider(
            create: (context) {
              final limits = RewardedAdLimitController(
                  rewardedAdLimitPersistence);
              limits.getLatestFromStore();
              return limits;
            },
          ),
          Provider<GamesServicesController?>.value(
              value: gamesServicesController),
          ChangeNotifierProvider<CustomVersesController>.value(
              value: customVersesController),
          Provider<AdsController?>.value(value: adsController),
          ChangeNotifierProvider<InAppPurchaseController?>.value(
              value: inAppPurchaseController),
          Provider<SettingsController>(
            lazy: false,
            create: (context) => SettingsController(
              persistence: settingsPersistence,
            )..loadStateFromPersistence(),
          ),
          ProxyProvider2<SettingsController, ValueNotifier<AppLifecycleState>,
              AudioController>(
            // Ensures that the AudioController is created on startup,
            // and not "only when it's needed", as is default behavior.
            // This way, music starts immediately.
            lazy: false,
            create: (context) => AudioController()..initialize(),
            update: (context, settings, lifecycleNotifier, audio) {
              if (audio == null) throw ArgumentError.notNull();
              audio.attachSettings(settings);
              audio.attachLifecycleNotifier(lifecycleNotifier);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
          ),
          Provider(
            create: (context) => Palette(),
          ),
        ],
        child: Builder(builder: (context) {
          final palette = context.watch<Palette>();
          final settings = context.watch<SettingsController>();

          return ValueListenableBuilder<Locale>(
            valueListenable: settings.locale,
            builder: (context, locale, child) => MaterialApp.router(
              title: 'Flying Words',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: palette.gold,
                  surface: palette.backgroundMain,
                ),
                fontFamily: bodyFontFamily,
                textTheme: TextTheme(
                  bodyMedium: TextStyle(
                    color: palette.ink,
                    fontFamily: bodyFontFamily,
                  ),
                ),
                useMaterial3: true,
              ),
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              routeInformationProvider: _router.routeInformationProvider,
              routeInformationParser: _router.routeInformationParser,
              routerDelegate: _router.routerDelegate,
              scaffoldMessengerKey: scaffoldMessengerKey,
            ),
          );
        }),
      ),
    );
  }
}
