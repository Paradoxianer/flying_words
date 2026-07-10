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
| #15 Verse-Quelle | **Bibel-API anbinden** („Bridge" zu Bibelsoftware), damit beliebige Verse wählbar sind. Übersetzungslizenzen beachten; gemeinfreie Übersetzungen (z. B. Schlachter 1951, Luther 1912, KJV) bevorzugen. |
| #14 Leaderboard | **Google Play Games / Game Center** über den vorhandenen `GamesServicesController`. Kein eigenes Backend. |
| #17 Ads + #18 DSGVO | **Später, vor Release** als gemeinsames Paket (AdMob + UMP-Consent). Jetzt keine Priorität. |
| #7 Score | Formel existiert, ist aber buggy → wird über Issue D + #7 zusammen gelöst (Difficulty-Faktor ist mit `difficultyScoreFactor` schon angelegt). |
| #3 WinScreen | Fehler-Darstellung ist laut Kommentar drin; es fehlt die Vers-Präsentation (WinScreen braucht Zugriff auf die `Lesson`). |
| #2 Lokalisierung | Deutsch + Englisch via `flutter_localizations`/ARB. Verstexte werden über die Bibel-API pro Sprache/Übersetzung gelöst. |
| #9/#10 Musik/FX | Extern blockiert (Assets müssen produziert werden) — kein Code-Task. |

---

## Teil 3: Implementierungsplan

### Phase 1 — Stabilisieren (Fundament)
*Ziel: App kompiliert, Fortschritt wird zuverlässig gespeichert, Score stimmt.*

1. **Issue A**: `player_progress.dart` fixen (Import, `setScoreforVerse`-Logik, `calculateNewHighScore`, richtige `Score`-Typen, `getLatestFromStore` lädt auch `_progress`).
2. **Issue B**: `toJson`/`fromJson` für `Score` + `VerseProgress`, Round-Trip-Tests.
3. **Issue D + #7**: Score-Formel absichern (ms statt s, kein negativer Score) und Difficulty-Gewichtung final festlegen.
4. **Issue C**: Off-by-one der Fehleranzahl beheben (Ursache in `flying_words.dart` suchen).
5. **Issue E**: Wortliste ohne Duplikate ziehen.
6. **Issue I (Teil)**: Smoke-Test reparieren, damit Regressionen auffallen.

### Phase 2 — Gameplay-Feinschliff
*Ziel: Runder Spiel-Loop mit sichtbarem Fortschritt.*

7. **#3**: WinScreen zeigt den kompletten Vers mit markierten Fehlern (`TextProgress` wiederverwenden, `Lesson` an WinScreen durchreichen).
8. **#11**: Live-Scoreboard im PlayScreen (aktueller Score/Fehler während des Spiels).
9. **Issue H**: Fortschritt/Highscore in der Levelauswahl.
10. **Issue F**: Difficulty-Freischaltung mit Padlock.
11. **Issue G**: Bibeltext ausblenden (Eye-Button), optional Score-Bonus.

### Phase 3 — Inhalt & Reichweite
*Ziel: Beliebige Verse, zwei Sprachen, Hilfe.*

12. **#15**: Bibel-API-Anbindung — Datenschicht (`VerseRepository`), Vers-Auswahl-UI (Buch/Kapitel/Vers), Caching für Offline-Betrieb; kuratierte Standardliste bleibt als Einstieg.
13. **#2**: Lokalisierung DE/EN (ARB-Dateien, hardcodierte Strings extrahieren).
14. **#13**: Hilfe-Screen in der App (Spielregeln, Difficulties, Scoring).
15. **#6**: Share on Winning (`share_plus`, Score + Vers als Text).

### Phase 4 — Release-Vorbereitung
16. **#14**: Games Services aktivieren (Leaderboard, dann Achievements — TODO in `lesson.dart`/`player_progress.dart`).
17. **#17 + #18**: AdMob + DSGVO/UMP-Consent-Dialog als Paket.
18. **#9/#10**: Eigene Musik/FX einbinden, sobald Assets vorliegen.
19. **Issue I (Rest)**: App-Titel/Branding, Logging, Icons, Store-Metadaten.

### Abhängigkeiten (Kurzfassung)

```
A ─┬─> B ─┬─> F, H (Freischaltung & Anzeige brauchen gespeicherten Fortschritt)
   │      └─> #14 Leaderboard (braucht korrekten, stabilen Score)
D/#7 ──────┘
#15 API ─> #2 Lokalisierung der Verse
#17 <─> #18 (Ads nur mit Consent)
```
