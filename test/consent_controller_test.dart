import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/legal/consent_controller.dart';
import 'package:flying_words/src/legal/persistence/memory_consent_persistence.dart';

void main() {
  group('ConsentController', () {
    test('starts unseen', () {
      final controller = ConsentController(MemoryOnlyConsentPersistence());
      expect(controller.privacyNoticeSeen, isFalse);
    });

    test('markPrivacyNoticeSeen() flips the flag and persists it', () async {
      final store = MemoryOnlyConsentPersistence();
      final controller = ConsentController(store);

      controller.markPrivacyNoticeSeen();
      expect(controller.privacyNoticeSeen, isTrue);

      // Flush the simulated async persistence write.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(await store.getPrivacyNoticeSeen(), isTrue);
    });

    test('getLatestFromStore loads a previously persisted flag', () async {
      final store = MemoryOnlyConsentPersistence();
      await store.savePrivacyNoticeSeen(true);

      final controller = ConsentController(store);
      await controller.getLatestFromStore();
      expect(controller.privacyNoticeSeen, isTrue);
    });

    test('markPrivacyNoticeSeen() is a no-op once already seen', () async {
      final store = MemoryOnlyConsentPersistence();
      final controller = ConsentController(store);
      controller.markPrivacyNoticeSeen();
      await Future<void>.delayed(const Duration(milliseconds: 600));

      var notified = 0;
      controller.addListener(() => notified++);
      controller.markPrivacyNoticeSeen();
      expect(notified, 0);
    });
  });
}
