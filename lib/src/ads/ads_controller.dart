// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';

import 'preloaded_banner_ad.dart';

/// Allows showing ads. A facade for `package:google_mobile_ads`.
class AdsController {
  static final Logger _log = Logger('AdsController');

  final MobileAds _instance;

  PreloadedBannerAd? _preloadedAd;

  /// Creates an [AdsController] that wraps around a [MobileAds] [instance].
  ///
  /// Example usage:
  ///
  ///     var controller = AdsController(MobileAds.instance);
  AdsController(MobileAds instance) : _instance = instance;

  void dispose() {
    _preloadedAd?.dispose();
  }

  /// Gathers consent (EEA/UK's GDPR "UMP" flow, showing a dialog only where
  /// legally required, #18) and, if the player is allowed to be shown ads,
  /// initializes the injected [MobileAds.instance].
  ///
  /// Consent must be resolved before the ads SDK is initialized - Google's
  /// policy requires that ad requests wait for it.
  Future<void> initialize() async {
    await _gatherConsent();
    if (await ConsentInformation.instance.canRequestAds()) {
      await _instance.initialize();
    } else {
      _log.warning('Ads consent not resolved; not initializing ads SDK.');
    }
  }

  Future<void> _gatherConsent() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
            if (formError != null) {
              _log.warning(
                  'Consent form error: ${formError.errorCode} ${formError.message}');
            }
            if (!completer.isCompleted) completer.complete();
          });
        } else if (!completer.isCompleted) {
          completer.complete();
        }
      },
      (formError) {
        _log.warning(
            'Consent info update failed: ${formError.errorCode} ${formError.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  /// Whether the platform's privacy-options entry point (to let the player
  /// change their ad consent choice later) must be shown, per Google's UMP
  /// policy. Surfaced as a settings entry once true.
  Future<bool> get privacyOptionsRequired async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  /// Re-opens the consent form so the player can change their ad consent
  /// choice (the persistent entry point Google's UMP policy requires).
  Future<void> showPrivacyOptionsForm() async {
    await ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        _log.warning(
            'Privacy options form error: ${formError.errorCode} ${formError.message}');
      }
    });
  }

  /// Starts preloading an ad to be used later.
  ///
  /// The work doesn't start immediately so that calling this doesn't have
  /// adverse effects (jank) during start of a new screen.
  void preloadAd() {
    // TODO: When ready, change this to the Ad Unit IDs provided by AdMob.
    //       The current values are AdMob's sample IDs.
    final adUnitId = defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-3940256099942544/6300978111'
        // iOS
        : 'ca-app-pub-3940256099942544/2934735716';
    _preloadedAd =
        PreloadedBannerAd(size: AdSize.mediumRectangle, adUnitId: adUnitId);

    // Wait a bit so that calling at start of a new screen doesn't have
    // adverse effects on performance.
    Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      return _preloadedAd!.load();
    });
  }

  /// Allows caller to take ownership of a [PreloadedBannerAd].
  ///
  /// If this method returns a non-null value, then the caller is responsible
  /// for disposing of the loaded ad.
  PreloadedBannerAd? takePreloadedAd() {
    final ad = _preloadedAd;
    _preloadedAd = null;
    return ad;
  }
}
