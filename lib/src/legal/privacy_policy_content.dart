// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../style/palette.dart';
import 'legal_section.dart';
import 'provider_info.dart';

/// The full privacy policy text, shared by [PrivacyScreen] and the
/// first-launch privacy notice (#111) so the legal text is only maintained
/// in one place.
class PrivacyPolicyContent extends StatelessWidget {
  final Palette palette;

  const PrivacyPolicyContent({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegalSection(
          title: l10n.privacyControllerTitle,
          body: l10n.privacyControllerBody(
            ProviderInfo.name,
            ProviderInfo.address,
            ProviderInfo.email,
          ),
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyOverviewTitle,
          body: l10n.privacyOverviewBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyLocalTitle,
          body: l10n.privacyLocalBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyVerseApiTitle,
          body: l10n.privacyVerseApiBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyAdsTitle,
          body: l10n.privacyAdsBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyGameServicesTitle,
          body: l10n.privacyGameServicesBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyCloudSaveTitle,
          body: l10n.privacyCloudSaveBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyThirdCountryTitle,
          body: l10n.privacyThirdCountryBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyRetentionTitle,
          body: l10n.privacyRetentionBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyRightsTitle,
          body: l10n.privacyRightsBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyComplaintTitle,
          body: l10n.privacyComplaintBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyAutomatedTitle,
          body: l10n.privacyAutomatedBody,
          palette: palette,
        ),
        LegalSection(
          title: l10n.privacyChangesTitle,
          body: l10n.privacyChangesBody(
            ProviderInfo.privacyPolicyLastUpdated,
          ),
          palette: palette,
        ),
      ],
    );
  }
}
