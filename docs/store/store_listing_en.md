# Store Listing (English) — Draft

## App name (max. 30 chars, Play)

Flying Words – Learn Verses

## Short description (max. 80 chars, Play)

Catch the flying words and memorize Bible verses while playing!

## Full description (max. 4000 chars, Play)

**Memorize Bible verses – as a game!**

In Flying Words, the words literally fly across your screen: tap the next word
of the verse before it disappears, and memorize the whole verse step by step.

**How it works**
🎯 The verse is shown at the top – the next word is highlighted
🪽 Words fly across the screen: the real ones and distractions
👆 Tap the right word in time and work your way through the verse
🏆 The faster and more accurate you are, the higher your score

**Features**
✅ Three difficulty levels (Seals I–III) – from relaxed learning to insane
mode, star rating based on your error rate
✅ Daily and weekly challenges with a streak bonus for practicing regularly
✅ Jokers (Hourglass, Forgiveness, Clarity, Bonus Time) help with tough
verses – earn them through challenges, buy them in the shop, or watch an ad
✅ Goldtinte in-game currency for the Joker shop – earned through flawless
runs, no betting or wagering mechanics of any kind
✅ "The Eye" – hide the text and play entirely from memory, with a score
bonus
✅ Add your own Bible passages and memorize them the same way
✅ Local leaderboard; on Android, Google Play Games leaderboards too
✅ Your progress is saved, fully playable offline

Great for youth groups, Bible study circles, families – and everyone who wants
to hide God's word in their heart (Psalm 119:11).

**License note:** Music by Mr Smith (CC BY 4.0),
freemusicarchive.org/music/mr-smith — will be replaced once original
music/sound assets are in place (#9, #10).

**Contains ads.** See the Data Safety notes (`docs/store/data_safety_de.md`).

## Keywords (App Store, max. 100 chars)

bible,verse,memorize,memory,scripture,christian,game,word game,faith,devotion

## What's new (example for v1.0)

First release: 6 verses, 3 difficulty levels, high scores.

## Still to produce

- [x] Screenshots — 24 total in `docs/store/screenshots/<language>/<device>/`,
      the same 6 shots (main menu, level selection, challenges, shop,
      gameplay, help) per language (`de`, `en`) and device class (`phone`
      1080×1920, `tablet` 1600×2560). Captured directly from the running web
      build (Playwright), no mockups.
- [ ] Feature graphic 1024×500 — still open, needs a deliberate
      design/branding decision (not auto-generated)
- [ ] Short promo video (optional)

## Known bug found while generating screenshots

The flying distractor words during gameplay are drawn from a hardcoded
**German-only** word list (`lib/src/games_services/random_words.dart`,
`bibleWords`), regardless of UI/verse language. In English, only the verse
text and the target word are correctly localized — the distractors stay
German (e.g. "Anbetung", "Hoffnung", "errettet"). This is a real gameplay
localization bug, not just a screenshot artifact, and should get its own
issue before the English listing is seriously promoted.

Note: the app UI is now localized into English (issue #2, closed) — the
screenshots above and the verse content
(`assets/verses/curated_en.json`) are genuinely English, not just this
listing text.
