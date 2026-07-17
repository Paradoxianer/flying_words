# Release-Checkliste (Google Play & App Store)

Was für die Veröffentlichung von Flying Words noch fehlt bzw. vorbereitet werden muss.
Verweise: Store-Texte in `docs/store/`, Datenschutz in `docs/DATENSCHUTZ_ENTWURF.md`,
Lizenzen in `docs/CREDITS.md`.

## Pflicht-Dokumente / Rechtliches

- [x] **Datenschutzerklärung** — ist inzwischen tatsächlich in der App implementiert
      (`lib/src/legal/privacy_policy_content.dart`, angezeigt unter Einstellungen →
      Datenschutz **und** im Erststart-Hinweis, #111/#105), nicht mehr nur der
      Entwurf `docs/DATENSCHUTZ_ENTWURF.md` (der ist jetzt veraltet/überholt).
      Für die Store-Konsolen wird trotzdem eine **öffentliche URL** gebraucht —
      die Web-Version (GitHub Pages) kann dafür direkt verlinkt werden
      (z. B. .../#/privacy), sonst Text separat als statische Seite hosten.
      **Trotzdem noch juristisch prüfen lassen**, bevor veröffentlicht wird.
- [ ] **Impressum/Anbieterkennzeichnung** — App-seitig bereits umgesetzt
      (Einstellungen → Impressum). Für den Store-Eintrag selbst noch verlinken.
      (applicationId ist `de.heilsarmee.flying_words`) in DE i. d. R. erforderlich
      (§ 5 DDG).
- [ ] **Lizenz-Attribution** — Musik von Mr Smith ist CC BY 4.0 → Namensnennung ist
      **verpflichtend** (in-App „Credits"-Screen oder im Store-Text). Siehe `docs/CREDITS.md`.
      Wird hinfällig, sobald #9 eigene Musik liefert.
- [x] **Bibeltext-Lizenz geklärt** — deutsche Standard-Übersetzung ist die
      **Menge-Bibel** (gemeinfrei, Menge † 1939; Details in `docs/CREDITS.md`).
      Offen: hardcodierte Verse in `levels.dart` auf Menge-Text umstellen;
      bei weiteren Übersetzungen über die Bibel-API (#15) Lizenz je Übersetzung prüfen.
- [x] **DSGVO-Consent-Dialog** (#18) — Erststart-Hinweis umgesetzt (#111), UMP-Consent-Flow
      für AdMob umgesetzt (#17, `AdsController._gatherConsent()`).

## Store-Einträge

- [x] Store-Texte DE/EN aktualisiert (Features auf den echten Stand gebracht) —
      `docs/store/store_listing_de.md`, `store_listing_en.md`. Noch offen: finaler
      Korrekturlesen-Durchgang, Musik-Lizenzhinweis anpassen sobald #9 landet.
- [x] Screenshots — 24 Stück in `docs/store/screenshots/<sprache>/<gerät>/`
      (DE/EN × Phone/Tablet, je 6 Motive), direkt aus dem Web-Build erzeugt.
      App-Store-Screenshots (iOS-spezifische Formate) noch offen.
- [ ] Feature-Grafik 1024×500 (Play, Pflicht), App-Icon 512×512 (Play) / 1024×1024 (iOS) —
      App-Icon existiert (`data/icon/`, #100), Feature-Grafik noch offen (Design-Entscheidung).
- [x] Google Play **Datensicherheits-Formular** (Data Safety) — Ausfüllhilfe basierend auf
      dem tatsächlichen Code-Stand: `docs/store/data_safety_de.md`. Vor dem Absenden im
      Formular nochmal gegen den dann aktuellen Stand prüfen (ändert sich mit #85/Crashlytics).
- [ ] Apple **Privacy Nutrition Labels** — dieselben Angaben für App Store Connect,
      `docs/store/data_safety_de.md` als Grundlage nutzbar.
- [x] Altersfreigabe-Fragebogen (IARC bei Play; Altersgruppe bei Apple) —
      Ausfüllhilfe: `docs/store/content_rating_de.md`. „Religiöse Inhalte" und
      „enthält Werbung" ehrlich angegeben, kein Glücksspiel (bewusste Design-Entscheidung, #54).
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
