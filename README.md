**Flying Words** is a Flutter game for memorizing Bible verses: a verse's
words fly across the screen one at a time, and you tap the correct next
word to assemble it from memory. Progress unlocks in three "Seals"
(difficulty levels) per verse, star ratings reward accuracy, and players
can add their own verses on top of a curated set.

- German and English UI and Bible content (`flutter_localizations`, see
  _Localization_ below)
- Runs on Android, iOS and the web (Flutter web build, see #30)
- Curated verses ship as bundled JSON; players can add their own via the
  [bolls.life](https://bolls.life) Bible API (`lib/src/verses`)
- Local score/progress tracking, no backend required
- Optional integrations for ads, achievements/leaderboards and crash
  reporting - all off by default until their store accounts are set up
  (see _Integrations_ below)

The full backlog and release plan live in
[`docs/ISSUES_UND_PLAN.md`](docs/ISSUES_UND_PLAN.md) and the project's
[GitHub issues](https://github.com/Paradoxianer/flying_words/issues).


# Getting started

    flutter pub get
    flutter run

This assumes you have an Android emulator, iOS Simulator, an attached
physical device, or a desktop/web target enabled.

Common development commands:

```bash
flutter analyze --no-fatal-infos   # static analysis
flutter test                       # run the test suite
flutter gen-l10n                   # regenerate lib/l10n/gen after editing an .arb file
flutter build web --no-web-resources-cdn   # production web build (bundles CanvasKit locally)
```

Whenever you add or change a string in `lib/l10n/app_de.arb` or
`app_en.arb`, run `flutter gen-l10n` before building or testing - the
generated `lib/l10n/gen/` sources aren't committed to the repo.


## Code organization

Code is organized feature-first under `lib/src`:

```
lib
├── src
│   ├── ads               # google_mobile_ads facade + AdMob UMP consent flow
│   ├── app_lifecycle
│   ├── audio
│   ├── crashlytics
│   ├── game_internals     # Lesson, LevelState, scoring
│   ├── games_services     # Play Games Services / Game Center facade
│   ├── help                # in-app rules screen
│   ├── in_app_purchase     # present in the template, currently unused (no IAP)
│   ├── legal               # Impressum / privacy policy screens
│   ├── level_selection
│   ├── main_menu
│   ├── play_session         # the flying-words gameplay + win celebration
│   ├── player_progress
│   ├── settings
│   ├── style               # design tokens, shared widgets
│   ├── verses               # curated + custom verse loading, bolls.life client
│   └── win_game
├── l10n                    # app_de.arb / app_en.arb (source of truth for all UI/legal strings)
└── main.dart
```

Verses live in `assets/verses/curated_de.json` and `curated_en.json`.
Both files intentionally reuse the same `number` per verse across
languages - `verseProgressKey()` keys player progress off that number,
not the display text, so switching the UI language doesn't reset
progress.


## Localization

UI strings and the Impressum/privacy policy text are defined once per
language in `lib/l10n/app_de.arb` / `app_en.arb` and consumed via the
generated `AppLocalizations` class. The initial locale follows the
device's language if it's supported (currently German or English),
falling back to German otherwise; an explicit choice in Settings always
wins (see `resolveInitialLocale` in `lib/src/settings/settings.dart`).

Bible content itself is loaded separately per language
(`loadCuratedVerses`) since it's not just UI chrome - see
`docs/CREDITS.md` for the licensing status of each translation in use.


# Integrations

The integrations below ship in the codebase but are disabled until
their respective store accounts exist - `lib/main.dart` keeps their
controllers `null` behind commented-out setup blocks. Uncomment the
relevant block once you've completed the steps for that integration.

## Ads (AdMob)

Implemented via `google_mobile_ads` in `lib/src/ads/`. `AdsController`
already runs Google's User Messaging Platform (UMP) consent flow before
initializing the ads SDK, and exposes a "reopen consent form" entry
point required by Google's policy - see the settings screen and
`lib/src/legal/privacy_screen.dart`.

To enable ads:

1. Set up an [AdMob](https://admob.google.com/) account and create an app there.
2. Get the app's AdMob _App ID_ and set it in
   `android/app/src/main/AndroidManifest.xml`
   (`com.google.android.gms.ads.APPLICATION_ID`) and
   `ios/Runner/Info.plist` (`GADApplicationIdentifier`).
3. Create an _Ad unit_ and update the sample IDs in
   `lib/src/ads/ads_controller.dart` (`preloadAd()`) with the real ones.
4. Uncomment the `AdsController` setup block in `lib/main.dart`.

See issue #17 for the current status.

## In-app purchases

The `in_app_purchase` package and its facade in
`lib/src/in_app_purchase/` are present but **intentionally unused** -
this project only monetizes through ads, not purchases. The
`InAppPurchaseController` stays `null` in `lib/main.dart`, so the
"Remove ads" settings entry never renders. If that changes, the code is
ready: fill in a real product ID in `ad_removal.dart` and uncomment the
setup block in `lib/main.dart`.

## Games Services (Game Center & Play Games Services)

Implemented via `package:games_services` in `lib/src/games_services/`,
disabled by default. Powers achievements and the leaderboard (#14);
enabling it requires setting up Game Center in App Store Connect and
Play Games Services in Google Play Console, then filling in the real
leaderboard/achievement IDs in `games_services.dart` and uncommenting
the setup block in `lib/main.dart`.

## Crashlytics

Optional, disabled by default; see `lib/src/crashlytics/`. Even without
Firebase configured, log messages still print to the console via the
`Logger` setup in `main.dart`. To enable Firebase Crashlytics, follow
[FlutterFire's setup guide](https://firebase.flutter.dev/docs/crashlytics/overview/),
run `flutterfire configure`, and uncomment the Crashlytics block in
`lib/main.dart`.


# Legal (Impressum / Datenschutz)

`lib/src/legal/` holds the in-app Impressum and privacy policy screens,
reachable from Settings. The actual provider identity (name, address,
contact) is centralized in `lib/src/legal/provider_info.dart` - fill
that in before release; it flows into both screens and both languages
automatically. See issue #18.


# Credits & licensing

Third-party asset attributions (music, sound effects, fonts, Bible
translations) are tracked in [`docs/CREDITS.md`](docs/CREDITS.md) - keep
it up to date whenever an asset or Bible translation is added, since
some of these carry mandatory attribution requirements.

This project is based on the
[Flutter Casual Games Template](https://github.com/flutter/samples)
(BSD-3-Clause, see `LICENSE`).


# Troubleshooting

## CocoaPods

When upgrading to higher versions of Flutter or plugins, you might encounter an error when
building the iOS or macOS app. A good first thing to try is to delete the `ios/Podfile.lock`
file (or `macos/Podfile.lock`, respectively), then trying to build again. (You can achieve
a more thorough cleanup by running `flutter clean` instead.)

## Warnings in console

When running the game for the first time, you might see warnings like the following:

> Note: Some input files use or override a deprecated API.

or

> warning: 'viewState' was deprecated in macOS 11.0: Use -initWithState: instead

These warnings come from the various plugins the app depends on. They are not harmful
and can be ignored - they're meant for the plugin authors, not for the app developer.
