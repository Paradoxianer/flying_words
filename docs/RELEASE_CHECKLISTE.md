# Release-Checkliste (Google Play & App Store)

Was für die Veröffentlichung von Flying Words noch fehlt bzw. vorbereitet werden muss.
Verweise: Store-Texte in `docs/store/`, Datenschutz in `docs/DATENSCHUTZ_ENTWURF.md`,
Lizenzen in `docs/CREDITS.md`.

## Pflicht-Dokumente / Rechtliches

- [ ] **Datenschutzerklärung** — von beiden Stores verpflichtend verlangt, sobald die App
      Daten verarbeitet (Crashlytics, Games Services, später AdMob). Muss unter einer
      **öffentlichen URL** erreichbar sein (z. B. GitHub Pages aus diesem Repo).
      Entwurf: `docs/DATENSCHUTZ_ENTWURF.md` → **juristisch prüfen lassen!**
- [ ] **Impressum/Anbieterkennzeichnung** — bei Veröffentlichung durch eine Organisation
      (applicationId ist `de.heilsarmee.flying_words`) in DE i. d. R. erforderlich
      (§ 5 DDG). In Store-Eintrag und/oder App verlinken.
- [ ] **Lizenz-Attribution** — Musik von Mr Smith ist CC BY 4.0 → Namensnennung ist
      **verpflichtend** (in-App „Credits"-Screen oder im Store-Text). Siehe `docs/CREDITS.md`.
- [ ] **Bibeltext-Lizenz klären** — die verwendete Übersetzung identifizieren und
      dokumentieren. Gemeinfrei sind z. B. Schlachter 1951, Luther 1912, Elberfelder 1905.
      Moderne Übersetzungen (LUT 2017, ELB 2006, HFA, NGÜ …) sind lizenzpflichtig!
      Spätestens bei der Bibel-API-Anbindung (#15) entscheidend.
- [ ] **DSGVO-Consent-Dialog** (#18) — spätestens mit AdMob (#17) nötig (Google UMP SDK).

## Store-Einträge

- [ ] Store-Texte DE/EN — Entwürfe: `docs/store/store_listing_de.md`, `store_listing_en.md`
- [ ] Screenshots: Play min. 2 (Phone), besser 4–8; App Store je Gerätegröße
- [ ] Feature-Grafik 1024×500 (Play, Pflicht), App-Icon 512×512 (Play) / 1024×1024 (iOS)
- [ ] Google Play **Datensicherheits-Formular** (Data Safety) — Angaben müssen zur
      Datenschutzerklärung passen (Crashlytics: Crash-Logs/Geräte-IDs; Games Services:
      Spieler-ID, Scores; AdMob: Werbe-ID)
- [ ] Apple **Privacy Nutrition Labels** — dieselben Angaben für App Store Connect
- [ ] Altersfreigabe-Fragebogen (IARC bei Play; Altersgruppe bei Apple).
      Inhaltlich unkritisch; „religiöse Inhalte" ehrlich angeben
- [ ] Kategorie: Lernen/Bildung oder Wortspiele; Schlagworte (siehe Store-Texte)

## Technisch vor Release

- [ ] `MaterialApp.title` von „Flutter Demo" auf „Flying Words" ändern (Issue I)
- [ ] iOS Bundle-ID prüfen (Android ist `de.heilsarmee.flying_words`)
- [ ] Release-Signing: Android Keystore + `key.properties` (nicht einchecken!),
      Play App Signing aktivieren
- [ ] Versionierung in `pubspec.yaml` (`version: x.y.z+build`)
- [ ] Crashlytics aktivieren (Code liegt auskommentiert in `main.dart`) — erst NACH
      Datenschutzerklärung/Consent
- [ ] Games Services konfigurieren (#14): Leaderboard-/Achievement-IDs in
      Play Console & App Store Connect anlegen
- [ ] `README.md` neu schreiben — aktuell noch überwiegend die Template-Anleitung,
      sollte das eigentliche Spiel beschreiben (+ Build-Anleitung)
- [ ] `CHANGELOG.md` beginnen (auch als Basis für „Was ist neu"-Store-Texte)

## Qualität

- [ ] Alle Bugs aus Phase 1 des Plans behoben (`docs/ISSUES_UND_PLAN.md`)
- [ ] Tests grün (`flutter test`), `flutter analyze` ohne Fehler
- [ ] Test auf kleinem Gerät (Touch-Ziele!) und Tablet
- [ ] Offline-Verhalten prüfen (App muss ohne Netz spielbar bleiben)
