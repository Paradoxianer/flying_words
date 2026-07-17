# Google Play „Datensicherheit"-Formular — Ausfüllhilfe

> Stand 17.07.2026, basierend auf dem tatsächlichen Verhalten der App zu
> diesem Zeitpunkt (siehe `lib/src/legal/privacy_policy_content.dart` und die
> `privacy*`-Einträge in `lib/l10n/app_de.arb` — das ist die Quelle der
> Wahrheit, diese Datei fasst sie nur fürs Play-Console-Formular zusammen).
> **Vor dem Absenden im Formular nochmal gegen den aktuellen Code-Stand
> prüfen** — Angaben hier veralten, sobald sich die Datenverarbeitung ändert
> (z. B. sobald #85 Cloud-Speicherung oder Crashlytics aktiv werden).

## Grundprinzip

Flying Words betreibt **keine eigenen Server**. Es gibt zwei Kategorien:

1. **Rein lokale Daten** — verlassen das Gerät nie, zählen bei Play NICHT als
   "gesammelte" Daten im Sinne des Formulars (nur *gespeicherte*, nicht
   *übertragene* Daten). Trotzdem der Vollständigkeit halber gelistet.
2. **An Drittanbieter übertragene Daten** — Google AdMob, optional Google Play
   Games Services. Das sind die eigentlich meldepflichtigen Punkte.

## Sammelt diese App Nutzerdaten? → **Ja**

(Wegen AdMob und der optionalen Play-Games-Anmeldung — auch wenn die App
selbst nichts sammelt/speichert, "sammeln" im Play-Sinne schließt die
Weitergabe an eingebundene Drittanbieter-SDKs mit ein.)

## Datentypen

### Gerätekennungen

- **Werbe-ID** (Advertising ID)
  - Gesammelt: Ja (über Google AdMob)
  - Geteilt: Ja (mit Google/AdMob)
  - Zweck: Werbung oder Marketing
  - Optional oder verpflichtend: **Optional** in Bezug auf Personalisierung
    (UMP-Consent-Dialog beim ersten Start, abschaltbar über Einstellungen →
    „Datenschutzeinstellungen für Werbung"). Nicht-personalisierte Werbung
    kann auch bei widerrufener Einwilligung weiter Basisdaten verarbeiten
    (Standard-AdMob-Verhalten).

### Spieler-ID / App-Aktivität (nur bei aktiver Anmeldung, Android)

- **Spieler-ID/Anzeigename bei Google Play Games Services**
  - Gesammelt: Ja, aber nur wenn der Spieler sich **aktiv und freiwillig**
    anmeldet (Bestenliste/Erfolge). Ohne Anmeldung: nein.
  - Geteilt: Ja (mit Google Play Games Services)
  - Zweck: App-Funktionalität (Bestenliste, Erfolge)
  - Optional oder verpflichtend: **Optional** — die App ist ohne Anmeldung
    vollständig offline nutzbar.

### Nicht gesammelt / nicht zutreffend

Explizit **"Nein"** ankreuzen für: Standort, Kontakte, finanzielle Infos,
Gesundheitsdaten, Nachrichten, Fotos/Videos, Audiodateien, Browserverlauf,
Suchverlauf, personenbezogene Namen/E-Mail (der Spielername ist frei wählbar,
rein lokal, wird nie übertragen).

**Wichtig:** Es findet aktuell **kein Crash-Reporting/Analytics** statt —
`firebase_crashlytics` ist im Code vorbereitet, aber die Initialisierung in
`main.dart` ist bewusst auskommentiert und nicht aktiv. Sobald das aktiviert
wird, muss dieses Formular (Absturzprotokolle, Diagnosedaten) entsprechend
ergänzt werden — bis dahin **nicht** als gesammelt angeben, das wäre falsch.

### Bibelvers-Abruf (bolls.life API)

Für frei wählbare eigene Bibelstellen kontaktiert die App die öffentliche
Schnittstelle von bolls.life. Übertragen werden nur Buch/Kapitel/Vers als
Zahlen — **keine personenbezogenen Daten**, taucht daher im Formular nicht
als Datentyp auf (kein Nutzer-Identifikator wird übermittelt).

## Sicherheitspraktiken

- **Datenübertragung verschlüsselt?** Ja (HTTPS für AdMob, Play Games API,
  bolls.life-Abruf).
- **Können Nutzer die Löschung ihrer Daten verlangen?** Für lokale Daten: ja,
  jederzeit über „Fortschritt zurücksetzen" in den Einstellungen (#101) oder
  durch Deinstallation. Für bei Google gespeicherte Daten (Play Games,
  Werbe-ID): Verweis auf die jeweiligen Google-Kontoeinstellungen.
- **Unabhängige Sicherheitsprüfung?** Nein (kleines Indie-Projekt, keine
  externe Zertifizierung vorhanden).

## Zielgruppe

Nicht primär für Kinder unter 13 beworben, aber auch keine Inhalte, die eine
Altersbeschränkung erfordern würden. Falls die Play-Console explizit nach
„richtet sich (auch) an Kinder" fragt: **Nein** ankreuzen, sofern die App
nicht gezielt im Kids-Bereich gelistet werden soll — das hat Auswirkungen auf
erlaubte Werbeformate (COPPA-ähnliche Regeln), sollte bewusst entschieden
werden, nicht automatisch.
