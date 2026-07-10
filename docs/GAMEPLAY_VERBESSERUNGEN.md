# Gameplay-Verbesserungen: Engagement-Analyse

Analyse des Spiel-Loops (`play_session_screen.dart`, `flying_words.dart`, `level_state.dart`)
mit dem Ziel, das Spiel so motivierend („engaging") wie möglich zu machen.
Sortiert nach erwarteter Wirkung.

## 1. Es gibt keine Verlier-Möglichkeit (größter Hebel)

Aktuell endet **jede** Runde mit „Gewonnen!" — wer alle Wörter verpasst, bekommt
trotzdem Konfetti. Ohne Scheitern gibt es keine Spannung und kein „noch ein Versuch".

**Vorschlag:** Fehler-Limit pro Difficulty (z. B. slow: unbegrenzt, normal: 5, insane: 3),
visualisiert als Herzen/Marker. Bei Überschreitung: „Nochmal versuchen"-Screen mit
direktem Retry-Button (schneller Wiedereinstieg ist entscheidend).

## 2. Combo-/Streak-System

Richtige Antworten in Folge sollten sich aufschaukeln: Combo-Zähler ×2, ×3 …,
sichtbar im Spielbildschirm (passt zu Issue #11 Scoreboard), mit steigender
SFX-Tonhöhe. Ein Fehler bricht die Combo. Das belohnt Konzentration und macht
fehlerfreie Runden zum eigentlichen Ziel — genau richtig für eine Lern-App.

## 3. Zeitdruck sichtbar machen

Die Wörter fliegen nach außen und verschwinden einfach (`end: 1.15`). Dass die Zeit
abläuft, spürt man kaum. **Vorschlag:** Wörter färben sich rot / pulsieren, je näher
sie dem Rand kommen, oder ein dezenter Kreis-Timer um das Zentrum. Zusätzlich:
Wörter beim Erscheinen kurz klein starten und „aufpoppen" (Anticipation).

## 4. Bessere Ablenkungswörter (echte Schwierigkeit statt Zufall)

`_randomWordsList` zieht Distraktoren rein zufällig aus `bibleWords`. Zufällige Wörter
sind leicht auszuschließen. **Vorschlag** (pro Difficulty steigernd):

- slow: zufällige Wörter (wie jetzt)
- normal: Wörter aus **demselben Vers** (spätere/frühere Wörter) — man muss die
  Reihenfolge wirklich können
- insane: ähnliche Wörter (gleicher Anfangsbuchstabe, ähnliche Länge, gebeugte Formen)

Außerdem: Winkel-Jitter für die Positionen (TODO steht schon im Code, Zeile 59) —
aktuell sind die Positionen deterministisch verteilt und damit vorhersagbar.

## 5. „Juice" — unmittelbares Feedback

- **Richtig:** Wort fliegt animiert an seine Stelle im Verstext oben (statt einfach zu
  verschwinden) — verbindet Aktion und Lernziel; kleiner Partikel-/Glitzer-Effekt.
- **Falsch:** kurzes rotes Aufblitzen + leichtes Screen-Shake + Vibration
  (`HapticFeedback.lightImpact`).
- Getipptes falsches Wort sollte verschwinden oder ausgrauen (aktuell passiert
  visuell nichts, man kann dasselbe falsche Wort mehrfach antippen).

## 6. Meta-Progression (Wiederkommen belohnen)

- **Sterne pro Vers/Difficulty** (3 = fehlerfrei, 2 = ≤2 Fehler, 1 = geschafft) in der
  Levelauswahl (baut auf Issue H auf).
- **Difficulty-Freischaltung** mit Padlock (Issue F) — gibt kurzfristige Ziele.
- **Tages-Streak / „Vers des Tages"**: einfacher täglicher Anreiz, sehr wirksam bei
  Lern-Apps (vgl. Duolingo).
- Achievements über Play Games / Game Center (Grundgerüst existiert schon).

## 7. Risk/Reward: Text ausblenden (eye.png, Issue G)

Der Auge-Button sollte nicht nur Komfort sein, sondern ein **Multiplikator**:
Wer den Verstext ausblendet, bekommt z. B. ×1,5 Score. So wird aus dem Lernziel
(auswendig können) ein Spielanreiz.

## 8. UX-Baustellen im Spiel-Loop

- **Back-Button** mitten im Spiel beendet die Runde ohne Rückfrage → Bestätigungsdialog
  oder Pause-Menü (Fortsetzen / Neustart / Verlassen).
- **Settings-Button** im Spiel pausiert das Spiel nicht — Wörter fliegen weiter.
- **Touch-Ziele**: Wörter sind reine `Text`-Widgets (fontSize 22) — auf kleinen
  Geräten schwer zu treffen. Padding/Hitbox vergrößern (min. 48×48 dp).
- Wörter können sich beim Spawnen **überlappen** (alle starten im Zentrum) —
  gestaffelter Start oder Mindestabstand.
- Erste Runde ohne Erklärung → einmaliges Tutorial-Overlay („Tippe das markierte
  Wort, bevor es verschwindet!"), gehört zu Issue #13 (Hilfe).

## 9. Audio

- Musik-Tempo/Titel je Difficulty (insane = treibender Track).
- SFX-Variation: bei Combo steigende Tonhöhe, eigener „Level geschafft ohne
  Fehler"-Jingle. (Hängt an #9/#10 eigene Musik/FX.)

## Priorisierung (Vorschlag)

| Prio | Maßnahme | Aufwand |
|---|---|---|
| 1 | Fehler-Limit + Retry-Screen (Verlieren möglich) | mittel |
| 2 | Tap-Feedback richtig/falsch (Juice, Haptik) | klein |
| 3 | Combo-System + Anzeige im PlayScreen (#11) | mittel |
| 4 | Distraktoren aus demselben Vers (normal/insane) | klein |
| 5 | Zeitdruck visualisieren | klein |
| 6 | Sterne + Freischaltung (F/H) | mittel |
| 7 | Eye-Modus als Score-Multiplikator (G) | klein |
| 8 | Pause/Back-Bestätigung, Touch-Ziele | klein |
| 9 | Tutorial-Overlay | mittel |
| 10 | Tages-Streak / Vers des Tages | mittel |
