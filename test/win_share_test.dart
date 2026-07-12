import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/win_game/win_share.dart';

void main() {
  group('winShareText', () {
    test('includes the verse, filled/empty stars, score and the play URL', () {
      final text = winShareText(
        verse: 'Johannes 3, 16',
        stars: 2,
        maxStars: 3,
        score: 420,
        blindRun: false,
      );
      expect(text.contains('Johannes 3, 16'), isTrue);
      expect(text.contains('★★☆'), isTrue);
      expect(text.contains('420 Punkte'), isTrue);
      expect(text.contains(flyingWordsUrl), isTrue);
      expect(text.contains('blind'), isFalse);
    });

    test('marks a blind run', () {
      final text = winShareText(
        verse: 'v',
        stars: 1,
        maxStars: 1,
        score: 10,
        blindRun: true,
      );
      expect(text.contains('★'), isTrue);
      expect(text.contains('blind'), isTrue);
    });
  });
}
