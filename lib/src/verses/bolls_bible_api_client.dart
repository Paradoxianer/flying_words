// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../game_internals/bible_reference.dart';
import 'bible_api_client.dart';
import 'bolls_books.dart';

/// Removes the markup bolls.life ships inside verse text so only the words
/// to memorize remain.
///
/// Real Menge sample (John 3:16) that this was built against:
///   "… seinen eingeborenen <i>(=einzigen)</i>  Sohn hingegeben hat, …"
/// Menge wraps his explanatory glosses in `<i>…</i>`; those are editorial
/// notes, not part of the verse, so the whole block is dropped. Removing it
/// leaves a double space, which is why whitespace is collapsed afterwards -
/// otherwise the game's `text.split(' ')` would produce an empty "word".
String cleanVerseText(String raw) {
  var text = raw;
  // Drop italic gloss blocks entirely (tag + content).
  text = text.replaceAll(RegExp(r'<i\b[^>]*>.*?</i>', dotAll: true), ' ');
  // Strip any remaining tags but keep their text.
  text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
  // Menge frames quoted speech with typographic brackets » « › ‹. When a
  // verse range is sliced out of a larger quotation (e.g. the blessing in
  // Numbers 6:24-26) these end up orphaned and stuck to words, so drop them.
  text = text.replaceAll(RegExp('[»«›‹]'), ' ');
  // Decode the few HTML entities that can slip through (\u escapes are
  // already handled by json.decode).
  const entities = {
    '&nbsp;': ' ',
    '&amp;': '&',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
    '&lt;': '<',
    '&gt;': '>',
  };
  entities.forEach((from, to) => text = text.replaceAll(from, to));
  // Collapse whitespace runs and trim.
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// A [BibleApiClient] backed by the free bolls.life JSON API.
///
/// NOTE: the live endpoint could not be reached from CI, so the request
/// flow is verified with a mocked HTTP client fed the real sample response.
/// The chapter-endpoint shape (a JSON array of `{verse, text}`) is the one
/// assumption still to confirm on a device with network.
class BollsBibleApiClient implements BibleApiClient {
  final http.Client _client;
  final String baseUrl;

  @override
  final String defaultTranslation;

  BollsBibleApiClient({
    http.Client? client,
    this.baseUrl = 'https://bolls.life',
    this.defaultTranslation = 'MB',
  }) : _client = client ?? http.Client();

  @override
  Future<FetchedVerse> fetchPassage(BibleReference reference,
      {String? translation}) async {
    final bookNumber = bollsBookNumbers[reference.book];
    if (bookNumber == null) {
      throw VerseFetchException('Unbekanntes Buch: ${reference.book}');
    }
    final tr = translation ?? defaultTranslation;
    final uri = Uri.parse(
        '$baseUrl/get-text/$tr/$bookNumber/${reference.chapter}/');

    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (e) {
      throw VerseFetchException('Netzwerkfehler: $e');
    }
    if (response.statusCode != 200) {
      throw VerseFetchException(
          'Server antwortete mit ${response.statusCode}');
    }

    final List verses;
    try {
      final decoded = json.decode(response.body);
      // The endpoint returns a JSON array; tolerate a {"verses": [...]} wrap.
      verses = decoded is Map ? (decoded['verses'] as List) : decoded as List;
    } catch (e) {
      throw VerseFetchException('Antwort konnte nicht gelesen werden: $e');
    }

    final selected = verses
        .cast<Map<String, dynamic>>()
        .where((v) {
          final n = v['verse'] as int;
          return n >= reference.verseStart && n <= reference.verseEnd;
        })
        .toList()
      ..sort((a, b) => (a['verse'] as int).compareTo(b['verse'] as int));

    if (selected.isEmpty) {
      throw VerseFetchException('Vers nicht gefunden: $reference');
    }

    final text = selected
        .map((v) => cleanVerseText(v['text'] as String))
        .where((t) => t.isNotEmpty)
        .join(' ');
    if (text.isEmpty) {
      throw VerseFetchException('Leerer Verstext: $reference');
    }
    return FetchedVerse(text: text, translation: tr);
  }
}
