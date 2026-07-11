# Neue Issues & Implementierungsplan

Stand: 2026-07-10 · Basis: Code-Analyse von `main` (Commit 904b27d) und Review der 12 offenen Issues.

Die Issues aus Teil 1 wurden inzwischen angelegt:
A=#21, B=#22, C=#23, D=#24, E=#25, F=#26, G=#27, H=#28, I=#29.

---

## Teil 1: Neue Issues

### Issue A (Bug): PlayerProgress speichert Scores nie & Compile-Fehler in player_progress.dart

> Beim Review von `lib/src/player_progress/player_progress.dart` sind mehrere Probleme aufgefallen, die zusammen dazu führen, dass der Spielfortschritt nie gespeichert wird (bzw. der Code vermutlich gar nicht kompiliert):
>
> 1. **Falscher Import** (Zeile 13): `package:flying_words/src/persistence/player_progress_persistence.dart` — die Datei liegt tatsächlich unter `src/player_progress/persistence/player_progress_persistence.dart`.
> 2. **`setScoreforVerse` speichert nie** (Zeilen 81–93):
>    - Wenn der Vers schon einen `VerseProgress` hat, wird der neue Score in keinem Fall eingetragen (der Code kehrt nur zurück oder tut nichts).
>    - Wenn der Vers noch keinen Fortschritt hat, wird zwar `savePlayerProgress` aufgerufen, aber der Score wurde vorher nie in `_progress` eingetragen.
>    - `verseProgress[difficulty]!.score` crasht mit Null-Check-Fehler, wenn für diese Difficulty noch kein Score existiert.
> 3. **`calculateNewHighScore`**: `if (key.compareTo(verse))` — `compareTo` liefert `int`, kein `bool` → Compile-Fehler. Gemeint ist vermutlich `key == verse`.
> 4. **Falscher `Score`-Typ**: `player_progress_persistence.dart` und `local_storage_player_progress_persistence.dart` importieren `Score` aus dem *Paket* `games_services` statt der eigenen Klasse aus `lib/src/games_services/score.dart`.
> 5. `_playerScore` wird beim Gewinnen nie aktualisiert; `getLatestFromStore` lädt `_progress` nicht aus dem Store.
>
> Betrifft die Baustelle aus Commit fd28dcb („Implemented most of the Playerprogress … still some issues i need to fix"). Hängt zusammen mit Issue B (JSON-Serialisierung).

Label: `bug`

### Issue B (Bug): JSON-Serialisierung für VerseProgress/Score fehlt — Persistenz crasht zur Laufzeit

> In `local_storage_player_progress_persistence.dart`:
>
> - `savePlayerProgress` ruft `json.encode(playerProgress)` auf — `VerseProgress` und `Score` haben aber kein `toJson()` → `JsonUnsupportedObjectError` zur Laufzeit.
> - `getPlayerProgress` castet `json.decode(jsonString)` direkt auf `Map<String, VerseProgress>` → `TypeError`, sobald einmal Daten gespeichert wären.
> - Auch der `Difficulty`-Enum-Key muss beim (De-)Serialisieren auf einen String gemappt werden, da JSON nur String-Keys erlaubt.
>
> Vorschlag: `toJson()`/`fromJson()` für `Score` und `VerseProgress` implementieren (Difficulty via `name`/`values.byName`) und Round-Trip-Unit-Tests dafür schreiben.
>
> Abhängig von / gehört zu Issue A.

Label: `bug`

### Issue C (Bug): WinScreen zeigt Fehleranzahl um 1 zu niedrig an („Errors: -1" bei fehlerfreiem Spiel)

> `lib/src/win_game/win_game_screen.dart` Zeile 59: `'Errors: ${errors-1}\n'` — bei 0 Fehlern wird „-1" angezeigt. Das `-1` wirkt wie ein Workaround für ein Zählproblem an anderer Stelle; die Ursache sollte gefunden und das `-1` entfernt werden (vermutlich zählt der AnimationStatus-Listener in `flying_words.dart` beim letzten Wort fälschlich einen Fehler, oder es ist schlicht falsch).
>
> Zusammenhang mit #3 (Vers mit Fehlern beim Gewinnen anzeigen).

Label: `bug`

### Issue D (Bug): Score-Berechnung — Division durch Null und negative Scores

> `lib/src/games_services/score.dart`, `Score.fromResult` (Zeile 26):
>
> - `maxScore ~/ (duration.inSeconds*10)` → **Division durch Null**, wenn das Level in unter 1 Sekunde gelöst wird (theoretisch möglich, z. B. bei sehr kurzen Versen).
> - Bei vielen Fehlern wird der Score **negativ**. `VerseProgress.finished()` prüft auf `score > 0` — ein gewonnenes Level mit schlechtem Score würde als „nicht geschafft" gewertet.
>
> Vorschlag: Duration in Millisekunden rechnen und auf ein Minimum clampen; Score bei 0 (oder einem Mindestwert für „gewonnen") deckeln. Formel-Details gehören zu #7.
>
> Teilaspekt von #7 (Calculate the Score correctly).

Label: `bug`

### Issue E (Bug): Zufällige Wortliste kann das richtige Wort doppelt bzw. Duplikate enthalten

> `lib/src/play_session/flying_words.dart`, `_randomWordsList` (Zeilen 51–71):
>
> - Wenn ein zufällig gewähltes Ablenkungswort dem gesuchten Wort entspricht, wird nur **einmal** neu gewürfelt — der zweite Wurf kann wieder das gesuchte Wort treffen. Dann fliegen zwei „richtige" Wörter, aber nur eines zählt als korrekt.
> - Ablenkungswörter untereinander können ebenfalls doppelt vorkommen.
>
> Vorschlag: Ziehen ohne Zurücklegen (Kandidatenliste mischen, erste n nehmen) und das gesuchte Wort dabei ausschließen.

Label: `bug`

### Issue F (Feature): Schwierigkeitsgrade sperren/freischalten (padlock)

> `assets/images/padlock.png` wurde in Commit 61e98cb dafür schon eingecheckt. Idee: `normal` wird erst freigeschaltet, wenn `slow` für den Vers geschafft ist, `insane` erst nach `normal` (`VerseProgress.finished()` existiert dafür bereits).
>
> In `level_item.dart` gesperrte Difficulties mit dem Padlock überlagern und `onPressed` deaktivieren.
>
> Abhängig von Issue A/B (Fortschritt muss erst zuverlässig gespeichert werden).

Label: `enhancement`

### Issue G (Feature): Bibeltext im Spiel ausblendbar machen (eye)

> `assets/images/eye.png` wurde in Commit f3ac42f dafür schon eingecheckt. Idee: Ein Auge-Button am `TextProgress`-Widget blendet den Verstext aus/ein, damit man „ohne Spickzettel" trainieren kann. Optional: Bonus-Punkte, wenn der Text ausgeblendet war (→ Score-Formel #7).

Label: `enhancement`

### Issue H (Feature): Fortschritt/Highscore pro Vers in der Levelauswahl anzeigen

> `PlayerProgress.getScoreforVerse()` existiert, wird aber nirgends genutzt. In `level_selection_screen.dart`/`level_item.dart` sollte pro Vers sichtbar sein, welche Difficulty geschafft ist (z. B. Marker-Icon voll deckend statt `Opacity 0.5`) und welcher Highscore erreicht wurde.
>
> Abhängig von Issue A/B; verwandt mit Issue F.

Label: `enhancement`

### Issue I (Tech-Debt): Aufräumen — App-Titel, print() → Logger, Tests reparieren

> - `MaterialApp.title` ist noch „Flutter Demo" (`main.dart` Zeile 254).
> - Mehrere `print()`/`debugPrint()`-Aufrufe in `flying_words.dart`, `level_state.dart`, `text_progress.dart` sollten durch `Logger` ersetzt oder entfernt werden.
> - `test/smoke_test.dart` stammt noch vom Template und passt vermutlich nicht mehr zum umgebauten Spiel (Levelauswahl/Play-Flow); Tests reparieren und für Score/Persistenz erweitern.

Label: keine / `enhancement`

---

## Teil 2: Getroffene Entscheidungen (Klärung bestehender Issues)

| Issue | Entscheidung |
|---|---|
| #15 Verse-Quelle | **Bibel-API anbinden**: bolls.life-API, deutsche Standard-Übersetzung **Menge-Bibel** (`MB`) — gut verständlich und gemeinfrei (Menge † 1939; nicht die „Menge 2020"-Revision!). Fallback: Zefania-XML als Offline-Bundle. |
| #14 Leaderboard | **Google Play Games / Game Center** über den vorhandenen `GamesServicesController`. Kein eigenes Backend. |
| #17 Ads + #18 DSGVO | **Später, vor Release** als gemeinsames Paket (AdMob + UMP-Consent). Jetzt keine Priorität. |
| #7 Score | Formel existiert, ist aber buggy → wird über Issue D + #7 zusammen gelöst (Difficulty-Faktor ist mit `difficultyScoreFactor` schon angelegt). |
| #3 WinScreen | Fehler-Darstellung ist laut Kommentar drin; es fehlt die Vers-Präsentation (WinScreen braucht Zugriff auf die `Lesson`). |
| #2 Lokalisierung | Zwei Ebenen: UI via `flutter_localizations`/ARB (neue Sprache = neue ARB-Datei); Verse über die Bibel-API mit Mapping Sprache → Übersetzung (`de` → Menge `MB`, `en` → WEB/KJV). Versliste referenziert Buch/Kapitel/Vers statt fixem Text. |
| #9/#10 Musik/FX | Extern blockiert (Assets müssen produziert werden) — kein Code-Task. |
| #30 PWA | Flutter-Web-Build als PWA, **Hosting über GitHub Pages** aus diesem Repo (CI-Workflow, `--base-href /flying_words/`). |

**Arbeitsweise:** Planungs-/Doku-Änderungen gehen direkt auf `main`;
Code-Änderungen laufen über Feature-Branches (`feature/<issue>-<slug>`) mit PR.

---

## Teil 3: Implementierungsplan

Status-Update **2026-07-10**: Phase 1 ist abgeschlossen (PRs #31–#35 gemerged),
die PWA läuft auf GitHub Pages (PR #37). Die beim Testen der PWA gefundenen
Issues #38–#40 sind eingeplant bzw. schon als PR umgesetzt.

### Phase 1 — Stabilisieren (Fundament) ✅ abgeschlossen
*Ziel: App kompiliert, Fortschritt wird zuverlässig gespeichert, Score stimmt.*

1. ✅ **#21**: `player_progress.dart` gefixt — Scores werden gespeichert (PR #31).
2. ✅ **#22**: `toJson`/`fromJson` für `Score` + `VerseProgress`, Round-Trip-Tests (PR #31).
3. ✅ **#24 + #7**: Score-Formel abgesichert — keine Division durch Null, min. 1 Punkt (PR #33). Feinjustierung der Faktoren bleibt in #7 offen.
4. ✅ **#23**: Off-by-one der Fehleranzahl behoben — Phantom-Fehler der Feier-Animation (PR #32).
5. ✅ **#25**: Wortliste ohne Duplikate (PR #34).
6. ✅ **#29 (Teil)**: Smoke-Test repariert + **CI-Workflow** (analyze + test bei jedem PR, PR #35).

### Phase 1b — Nachschläge aus dem PWA-Test *(neu)*
*Beim ersten Spielen der PWA gefundene Punkte — klein und direkt umsetzbar.*

7. 🔄 **#38**: Wort-Flugzeit unabhängig von Bildschirmgröße/Richtung (Bug; PR #41 offen).
8. ✅ **#39 (Konzept)**: Design-Diskussion abgeschlossen — **Beschluss: „Scriptorium + Arcade-Energie"** (Pergament/Tinte/Wachssiegel-Grundstimmung, satte Feedback-Momente im Spielfeld). Schwierigkeit = Siegel I/II/III; Sterne pro Vers **und** Stufe (I/II: bis ★★★, III: ★ Meisterstern, max. 7/Vers); Freischaltung streng ab ★★ der Vorstufe. Details im Kommentar auf #39. Umsetzung als eigene Redesign-Phase (s. u.).
9. 🔄 **#40**: Nutzername 24 statt 12 Zeichen (PR #42 offen).
10. **#36**: Upgrade auf aktuelles Flutter/Dart 3 — **vor Phase 2 einplanen**, damit neue Features nicht doppelt migriert werden müssen (ein einzelner PR; danach CI entpinnen und `--fatal-warnings` aktivieren).

### Phase 2 — Gameplay-Feinschliff
*Ziel: Runder Spiel-Loop mit sichtbarem Fortschritt.*

11. ✅ **#3**: WinScreen zeigt den kompletten Vers mit markierten Fehlern (PR #45).
12. ✅ **#11**: Live-Scoreboard im PlayScreen (PR #46).
13. **#27**: Bibeltext ausblenden (Eye-Button), optional Score-Bonus — unabhängig vom Redesign umsetzbar.

### Phase 2b — Redesign „Scriptorium" *(Beschluss vom 10.07.2026, siehe #39)*
*Kleine, reviewbare PRs; #26 und #28 werden hier miterledigt.*

14. ✅ **Theme/Token-Modul** (PR #47): Scriptorium-Palette, Cormorant + Source Serif gebundelt (OFL), `Score` speichert die Fehlerzahl, Sterne-/Freischaltungs-Modell implementiert.
15. ✅ **Versauswahl** (PR #48): Pergamentkarten, Wachssiegel I/II/III, Sterne-Anzeige → **#28** erledigt; Padlock-Freischaltung → **#26** erledigt.
16. ✅ **Spielfeld** (PR #49): Pergamentgrund, Tintenwörter, Klecks-Feedback (Fehlwort deaktiviert sich), Gold-Popup beim Fangen.
17. ✅ **Hauptmenü, WinScreen, Settings** (PR #50): Goldlinie/Untertitel im Menü, verdiente Sterne im WinScreen, Settings auf Deutsch. Regel-Fix: Sterne können nie sinken.
18. ✅ **Feinschliff** (PR #51): Combo-Serie (Scoreboard + Popup), Konfetti in Scriptorium-Farben, Icon-Hintergrund Pergament. Offen bleibt nur das Icon-Motiv selbst (bewusst beim Owner).

### Phase 2d — Spielbarkeit ✅ implementiert (PRs #60–#63, gestackt in dieser Reihenfolge)

1. ✅ **#56** (PR #60): Pause + Bestätigungsdialog beim Verlassen; Wörter verdeckt, Uhr stoppt, Pausenzeit zählt nicht in den Score.
2. ✅ **#57** (PR #61): Maus/Trackpad +45 % Flugzeit (Hover-Erkennung), einmaliger Hinweis.
3. ✅ **#55** (PR #62): Feier — Vers setzt sich lesbar zusammen (Wrap-Layout), WinScreen blendet über (Fade).
4. ✅ **#27** (PR #63): Eye-Button; Blind-Lauf (vor dem ersten Wort verdeckt, nie gespickt) = Score ×1,5.

### Phase 3 — Inhalt & Reichweite *(nächste Phase, Start nach Merge von #60–#63)*
*Ziel: Beliebige Verse in sauberem Datenmodell, dann Sprache & Reichweite.*

1. **#15a — Datenmodell**: `Lesson` bekommt Buch/Kapitel/Vers-Referenzen statt nur Text-String; kuratierte Liste als JSON-Asset (~10 Verse, **Menge-Bibel**-Text) statt hardcoded Dart. Grundlage für alles Weitere.
2. **#52 — Vers-Progression**: 3 Verse offen, Kette bis alle offen (`PlayerProgress.unlockedVerseCount`), versiegelte Karten in der Auswahl.
3. **#15b — Bibel-API**: `VerseRepository` gegen bolls.life (`MB`), Caching für Offline/PWA, Vers-Auswahl-UI (Buch/Kapitel/Vers); „Eigene Verse" in 3er-Paketen nach Abschluss der kuratierten Liste (#52-Regel).
4. **#2 — Lokalisierung**: ARB/`flutter_localizations` DE/EN; Verse pro Sprache über Übersetzungs-Mapping (`de`→MB, `en`→WEB).
5. **#13 — Hilfe-Screen**: Spielregeln, Siegel/Sterne-System, Joker (sobald vorhanden).
6. **#6 — Share on Winning**: `share_plus`, Vers + Score als Text.

### Phase 2c — Gameplay-Ausbau *(Ideen-Backlog, nach Phase 2d/3)*

- **#56**: Bestätigungsdialog + Pause/Blur beim Verlassen des Spiels (Quick Win, Bug-Charakter).
- **#55**: Feier-Animation umdrehen — der Vers setzt sich lesbar von außen zusammen und **blendet in den WinScreen über**.
- **#52**: Vers-Progression (3 offen → Kette bis ~10 → eigene Verse in 3er-Paketen; hängt an #15).
- **#53**: Daily/Weekly Challenges mit Jokern (Gnade, Sanduhr, Tintenlöscher, Federkiel).
- **#54**: Spielwährung „Goldtinte" — Verdienst + Joker-Shop, keine Eintrittskosten. **Kein Wett-/Einsatz-Modus** (Glücksspiel passt nicht zu den Werten des Herausgebers).
- **#57**: Maus/Touchpad-Ausgleich für die Desktop-PWA (+40–50 % Flugzeit bei Maus-Eingabe, einmaliger Hinweis).
- **#14 (erweitert)**: Bestenliste gestuft — lokal → Play Games/Game Center → Land/Welt (eigenes Backend).

### Phase 3 — Inhalt & Reichweite
*Ziel: Beliebige Verse, zwei Sprachen, Hilfe.*

16. **#15**: Bibel-API-Anbindung — Datenschicht (`VerseRepository`), Vers-Auswahl-UI (Buch/Kapitel/Vers), Caching für Offline-Betrieb; kuratierte Standardliste bleibt als Einstieg. Muss CORS-tauglich sein (PWA!).
17. **#2**: Lokalisierung DE/EN (ARB-Dateien, hardcodierte Strings extrahieren).
18. **#13**: Hilfe-Screen in der App (Spielregeln, Difficulties, Scoring).
19. **#6**: Share on Winning (`share_plus`, Score + Vers als Text).
20. **#30 (Rest)**: PWA-Feinschliff — Deploy läuft ✅ (PR #37); offen: Audio-/Offline-Verhalten testen, Icons/Theme-Farben.

### Phase 4 — Release-Vorbereitung
21. **#14**: Games Services aktivieren (Leaderboard, dann Achievements — TODO in `lesson.dart`/`player_progress.dart`).
22. **#17 + #18**: AdMob + DSGVO/UMP-Consent-Dialog als Paket.
23. **#9/#10**: Eigene Musik/FX einbinden, sobald Assets vorliegen.
24. **#29 (Rest)**: App-Titel/Branding, print() → Logger, README neu, Store-Metadaten.

### Abhängigkeiten (Kurzfassung)

```
#21 ─┬─> #22 ─┬─> #26, #28 (Freischaltung & Anzeige brauchen gespeicherten Fortschritt) ✅ erfüllt
     │        └─> #14 Leaderboard (braucht korrekten, stabilen Score)
#24/#7 ────────┘
#36 Flutter-Upgrade ─> vor Phase 2 (sonst doppelte Migration)
#39 Karten-Layout ─> #28 Fortschrittsanzeige
#15 API ─> #2 Lokalisierung der Verse
#17 <─> #18 (Ads nur mit Consent)
```
