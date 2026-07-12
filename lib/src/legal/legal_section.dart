// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../style/palette.dart';
import '../style/scriptorium_text.dart';

/// A titled paragraph, shared by the Impressum and privacy policy screens
/// (#18).
class LegalSection extends StatelessWidget {
  final String title;
  final String body;
  final Palette palette;

  const LegalSection({
    super.key,
    required this.title,
    required this.body,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ScriptoriumText.heading.copyWith(color: palette.gold),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: ScriptoriumText.body.copyWith(color: palette.inkFullOpacity),
          ),
        ],
      ),
    );
  }
}
