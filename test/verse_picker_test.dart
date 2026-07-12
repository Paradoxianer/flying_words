import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/bible_reference.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';
import 'package:flying_words/src/style/palette.dart';
import 'package:flying_words/src/verses/bible_api_client.dart';
import 'package:flying_words/src/verses/custom_verses_controller.dart';
import 'package:flying_words/src/verses/persistence/memory_custom_verses_persistence.dart';
import 'package:flying_words/src/verses/verse_picker.dart';
import 'package:provider/provider.dart';

class FakeBibleApiClient implements BibleApiClient {
  @override
  String get defaultTranslation => 'MB';

  bool fail = false;
  String text = 'Denn so sehr hat Gott die Welt geliebt';
  BibleReference? lastRequest;

  @override
  Future<FetchedVerse> fetchPassage(BibleReference reference,
      {String? translation}) async {
    lastRequest = reference;
    if (fail) throw const VerseFetchException('nicht gefunden');
    return FetchedVerse(text: text, translation: translation ?? 'MB');
  }
}

void main() {
  Widget host(CustomVersesController controller, PlayerProgress progress) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: controller),
        ChangeNotifierProvider.value(value: progress),
        Provider(create: (_) => Palette()),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showVersePicker(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('adds a verse for the chosen reference (default John 3:16)',
      (tester) async {
    final api = FakeBibleApiClient();
    final controller = CustomVersesController(
        store: MemoryCustomVersesPersistence(), api: api);
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());

    await tester.pumpWidget(host(controller, progress));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The defaults are John 3:16.
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    expect(api.lastRequest!.book, 'JHN');
    expect(api.lastRequest!.chapter, 3);
    expect(api.lastRequest!.verseStart, 16);
    expect(controller.verses, hasLength(1));
    expect(controller.verses.single.verse, 'Johannes 3, 16');
    // Dialog closed on success.
    expect(find.text('Hinzufügen'), findsNothing);
  });

  testWidgets('a fetch error is shown and the dialog stays open',
      (tester) async {
    final api = FakeBibleApiClient()..fail = true;
    final controller = CustomVersesController(
        store: MemoryCustomVersesPersistence(), api: api);
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());

    await tester.pumpWidget(host(controller, progress));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('picker-error')), findsOneWidget);
    expect(controller.verses, isEmpty);
    expect(find.text('Hinzufügen'), findsOneWidget);
  });

  testWidgets('a verse range builds a range display', (tester) async {
    final api = FakeBibleApiClient();
    final controller = CustomVersesController(
        store: MemoryCustomVersesPersistence(), api: api);
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());

    await tester.pumpWidget(host(controller, progress));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('chapter-field')), '6');
    await tester.enterText(find.byKey(const Key('from-field')), '24');
    await tester.enterText(find.byKey(const Key('to-field')), '26');
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    expect(api.lastRequest!.verseEnd, 26);
    expect(controller.verses.single.verse, 'Johannes 6, 24-26');
  });
}
