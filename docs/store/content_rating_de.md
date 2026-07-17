# Inhaltseinstufung (IARC-Fragebogen) — Ausfüllhilfe

> Der IARC-Fragebogen in der Play Console stellt konkrete Ja/Nein-Fragen pro
> Kategorie. Hier die erwarteten Antworten basierend auf dem tatsächlichen
> Inhalt der App — im Zweifel den Fragebogen selbst genau lesen, die exakten
> Formulierungen ändern sich gelegentlich.

## Gewalt

**Nein** — keinerlei Gewaltdarstellung. Das Spiel besteht aus Wörtern, die
über den Bildschirm fliegen und angetippt werden.

## Sexuelle Inhalte

**Nein**.

## Anstößige Sprache / Vulgarität

**Nein**. Die Bibeltexte selbst (Menge-Übersetzung u. a.) enthalten keine
vulgäre Sprache.

## Kontrollierte Substanzen (Drogen, Alkohol, Tabak)

**Nein** — keine Darstellung oder Bezugnahme.

## Glücksspiel

**Nein.** Explizit wichtig: Es gibt bewusst **keinen** Wett- oder
Einsatz-Mechanismus — das wurde bei der Konzeption der Spielwährung
(„Goldtinte", Issue #54) ausdrücklich verworfen, gerade weil Glücksspielnähe
nicht zu den Werten des Herausgebers passt. Goldtinte wird nur durch
Spielleistung verdient (fehlerfreie Läufe), nie durch Zufallsmechaniken
eingesetzt oder riskiert.

## Nutzergenerierte Inhalte

**Eingeschränkt zutreffend, aber nicht öffentlich.** Spieler können eigene
Bibelstellen über die Bibel-API hinzufügen — das sind aber nur Referenzen auf
öffentliche Bibeltexte (Buch/Kapitel/Vers), keine freien Texteingaben, und
werden nicht mit anderen Nutzern geteilt (rein lokal, kein Multiplayer/keine
öffentliche Anzeige). Die Frage nach "nutzergenerierte Inhalte, die andere
Nutzer sehen können" sollte daher mit **Nein** beantwortet werden.

## Standortfreigabe

**Nein** — die App fragt keine Standortdaten ab.

## Digitale Käufe / In-App-Käufe

**Aktuell Nein** (der Code für In-App-Käufe existiert, ist aber
auskommentiert/inaktiv — `InAppPurchaseController` wird in `main.dart` nicht
instanziiert). Sobald das aktiviert wird (z. B. „Werbung entfernen"), muss
diese Antwort auf **Ja** geändert werden.

## Werbung

**Ja** — die App zeigt Werbung über Google AdMob (Banner + Rewarded Ads im
Shop, siehe #17, #54). Muss im Fragebogen als "enthält Werbung" angegeben
werden, unabhängig von der Alterseinstufung selbst.

## Religiöse/weltanschauliche Inhalte

**Ja, ehrlich angeben.** Die App vermittelt Bibelverse als Kernkonzept
(Herausgeber: Heilsarmee). Das ist in den meisten Einstufungssystemen kein
Grund für eine höhere Alterseinstufung, sollte aber wahrheitsgemäß vermerkt
werden, falls danach gefragt wird — nicht verstecken.

## Erwartete Gesamteinstufung

Basierend auf den obigen Antworten: **PEGI 3 / ESRB Everyone / USK 0** oder
das jeweils niedrigste verfügbare Rating — die App hat keine
altersrelevanten Inhalte außer der (unbedenklichen) Religionsthematik und
enthält Werbung. Die finale Einstufung berechnet der IARC-Fragebogen
automatisch aus den Antworten, hier nur zur Erwartungssteuerung.
