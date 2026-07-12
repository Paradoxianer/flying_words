// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ui' show Locale;

/// Maps the USFM book codes used in our verse data (e.g. "JHN", "1CO") to
/// the numeric book ids bolls.life expects in its URLs (Genesis = 1 …
/// Revelation = 66). The numbering was confirmed against a real call:
/// John (JHN) is book 43 (`get-verse/MB/43/3/16/` returned John 3:16).
const Map<String, int> bollsBookNumbers = {
  'GEN': 1, 'EXO': 2, 'LEV': 3, 'NUM': 4, 'DEU': 5,
  'JOS': 6, 'JDG': 7, 'RUT': 8, '1SA': 9, '2SA': 10,
  '1KI': 11, '2KI': 12, '1CH': 13, '2CH': 14, 'EZR': 15,
  'NEH': 16, 'EST': 17, 'JOB': 18, 'PSA': 19, 'PRO': 20,
  'ECC': 21, 'SNG': 22, 'ISA': 23, 'JER': 24, 'LAM': 25,
  'EZK': 26, 'DAN': 27, 'HOS': 28, 'JOL': 29, 'AMO': 30,
  'OBA': 31, 'JON': 32, 'MIC': 33, 'NAM': 34, 'HAB': 35,
  'ZEP': 36, 'HAG': 37, 'ZEC': 38, 'MAL': 39, 'MAT': 40,
  'MRK': 41, 'LUK': 42, 'JHN': 43, 'ACT': 44, 'ROM': 45,
  '1CO': 46, '2CO': 47, 'GAL': 48, 'EPH': 49, 'PHP': 50,
  'COL': 51, '1TH': 52, '2TH': 53, '1TI': 54, '2TI': 55,
  'TIT': 56, 'PHM': 57, 'HEB': 58, 'JAS': 59, '1PE': 60,
  '2PE': 61, '1JN': 62, '2JN': 63, '3JN': 64, 'JUD': 65,
  'REV': 66,
};

/// German display names for the book codes, for the verse picker UI.
const Map<String, String> germanBookNames = {
  'GEN': '1. Mose', 'EXO': '2. Mose', 'LEV': '3. Mose', 'NUM': '4. Mose',
  'DEU': '5. Mose', 'JOS': 'Josua', 'JDG': 'Richter', 'RUT': 'Rut',
  '1SA': '1. Samuel', '2SA': '2. Samuel', '1KI': '1. Könige',
  '2KI': '2. Könige', '1CH': '1. Chronik', '2CH': '2. Chronik',
  'EZR': 'Esra', 'NEH': 'Nehemia', 'EST': 'Ester', 'JOB': 'Hiob',
  'PSA': 'Psalmen', 'PRO': 'Sprüche', 'ECC': 'Prediger',
  'SNG': 'Hoheslied', 'ISA': 'Jesaja', 'JER': 'Jeremia',
  'LAM': 'Klagelieder', 'EZK': 'Hesekiel', 'DAN': 'Daniel',
  'HOS': 'Hosea', 'JOL': 'Joel', 'AMO': 'Amos', 'OBA': 'Obadja',
  'JON': 'Jona', 'MIC': 'Micha', 'NAM': 'Nahum', 'HAB': 'Habakuk',
  'ZEP': 'Zefanja', 'HAG': 'Haggai', 'ZEC': 'Sacharja', 'MAL': 'Maleachi',
  'MAT': 'Matthäus', 'MRK': 'Markus', 'LUK': 'Lukas', 'JHN': 'Johannes',
  'ACT': 'Apostelgeschichte', 'ROM': 'Römer', '1CO': '1. Korinther',
  '2CO': '2. Korinther', 'GAL': 'Galater', 'EPH': 'Epheser',
  'PHP': 'Philipper', 'COL': 'Kolosser', '1TH': '1. Thessalonicher',
  '2TH': '2. Thessalonicher', '1TI': '1. Timotheus', '2TI': '2. Timotheus',
  'TIT': 'Titus', 'PHM': 'Philemon', 'HEB': 'Hebräer', 'JAS': 'Jakobus',
  '1PE': '1. Petrus', '2PE': '2. Petrus', '1JN': '1. Johannes',
  '2JN': '2. Johannes', '3JN': '3. Johannes', 'JUD': 'Judas',
  'REV': 'Offenbarung',
};

/// English display names for the book codes, for the verse picker UI (#2).
const Map<String, String> englishBookNames = {
  'GEN': 'Genesis', 'EXO': 'Exodus', 'LEV': 'Leviticus', 'NUM': 'Numbers',
  'DEU': 'Deuteronomy', 'JOS': 'Joshua', 'JDG': 'Judges', 'RUT': 'Ruth',
  '1SA': '1 Samuel', '2SA': '2 Samuel', '1KI': '1 Kings',
  '2KI': '2 Kings', '1CH': '1 Chronicles', '2CH': '2 Chronicles',
  'EZR': 'Ezra', 'NEH': 'Nehemiah', 'EST': 'Esther', 'JOB': 'Job',
  'PSA': 'Psalms', 'PRO': 'Proverbs', 'ECC': 'Ecclesiastes',
  'SNG': 'Song of Songs', 'ISA': 'Isaiah', 'JER': 'Jeremiah',
  'LAM': 'Lamentations', 'EZK': 'Ezekiel', 'DAN': 'Daniel',
  'HOS': 'Hosea', 'JOL': 'Joel', 'AMO': 'Amos', 'OBA': 'Obadiah',
  'JON': 'Jonah', 'MIC': 'Micah', 'NAM': 'Nahum', 'HAB': 'Habakkuk',
  'ZEP': 'Zephaniah', 'HAG': 'Haggai', 'ZEC': 'Zechariah', 'MAL': 'Malachi',
  'MAT': 'Matthew', 'MRK': 'Mark', 'LUK': 'Luke', 'JHN': 'John',
  'ACT': 'Acts', 'ROM': 'Romans', '1CO': '1 Corinthians',
  '2CO': '2 Corinthians', 'GAL': 'Galatians', 'EPH': 'Ephesians',
  'PHP': 'Philippians', 'COL': 'Colossians', '1TH': '1 Thessalonians',
  '2TH': '2 Thessalonians', '1TI': '1 Timothy', '2TI': '2 Timothy',
  'TIT': 'Titus', 'PHM': 'Philemon', 'HEB': 'Hebrews', 'JAS': 'James',
  '1PE': '1 Peter', '2PE': '2 Peter', '1JN': '1 John',
  '2JN': '2 John', '3JN': '3 John', 'JUD': 'Jude',
  'REV': 'Revelation',
};

/// Picks the book-name map matching [locale]'s language; German is the
/// fallback for any language we don't have book names for yet.
Map<String, String> bookNamesFor(Locale locale) =>
    locale.languageCode == 'en' ? englishBookNames : germanBookNames;
