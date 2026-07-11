import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/play_session/celebration_verse.dart';
import 'package:flying_words/src/style/palette.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('the verse assembles readable with errors marked',
      (tester) async {
    await tester.pumpWidget(Provider(
      create: (_) => Palette(),
      child: const MaterialApp(
        home: Scaffold(
          body: CelebrationVerse(
            words: ['Alpha', 'Beta', 'Gamma'],
            errors: {1},
          ),
        ),
      ),
    ));

    // All words are part of the layout from the start.
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);

    // Let the assembly animation finish.
    await tester.pumpAndSettle();

    final palette = Palette();
    Color colorOf(String word) =>
        tester.widget<Text>(find.text(word)).style!.color!;
    expect(colorOf('Beta'), palette.sealRed);
    expect(colorOf('Alpha'), palette.inkFullOpacity);

    // Fully faded in.
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Gamma'), matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 1.0);
  });
}
