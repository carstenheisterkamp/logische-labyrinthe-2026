%  Das Institut, ein spielbares Textadventure in Scryer Prolog.
%  Kursbeispiel: Logische Labyrinthe SoSe 2026, HSD
%
%  Starten:
%    scryer-prolog das_institut.pl
%    ?- play.
%
%  Enthaltene Prolog-Aspekte:
%    Fakten & Regeln, Unifikation, Backtracking, Cut (Green/Red),
%    Closed World Assumption (CWA), dynamische Praedikate, STRIPS-Modell,
%    Listen, Rekursion, Metapraedikate (findall, forall, maplist),
%    formatierte Ausgabe, DCG-Parser, Fehlerbehandlung,
%    Spielstand-Persistenz (write_term/read_term, Term-Serialisierung)
%
%  Determinismus-Angaben:
%  det:     genau eine Loesung, kein Backtracking danach.
%  semidet: eine Loesung oder keine.
%  nondet:  mehrere Loesungen moeglich (auch null).
%  multi:   mehrere Loesungen moeglich, mindestens eine.
%  failure: schlaegt immer fehl (z. B. repeat/fail-Loop).
%  Argument-Praefixe:
%  +      Eingabe (das Argument ist gebunden)
%  -      Ausgabe (das Argument wird gebunden)
%  ?      Ein- oder Ausgabe
%  @      Eingabe, wird nicht gebunden (nur inspiziert)
%  :      Meta-Argument (das Argument wird als Goal aufgerufen)

:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(charsio)).
:- use_module(library(format)).
:- use_module(library(time)).

% Scryer-kompatible Allquantifizierung.
% Explizite Formulierung des Negation-as-Failure-Prinzips hinter forall/2.
%! forall(:Bedingung, :Aktion) is det.
forall(Bedingung, Aktion) :-
    \+ (Bedingung, \+ Aktion).

% =============================================================================
%  STATISCHES WELTMODELL
% =============================================================================

%! raum(?Raum) is nondet.
raum(aussen).
raum(eingang).
raum(korridor).
raum(labor).
raum(archiv).
raum(geheimraum).

%! gegenstand(?Obj) is nondet.
%  Typpraedikat: nur explizit deklarierte Gegenstaende koennen aufgenommen werden.
gegenstand(brecheisen).
gegenstand(id_karte).
gegenstand(taschenlampe).
gegenstand(buch).
gegenstand(akte).

%! verbindet(+Von, +Nach) is semidet.
%  Frei begehbare Verbindung (kein Hindernis).
verbindet(eingang,  korridor).
verbindet(korridor, eingang).

%! tuer(+Von, +Nach, ?Tuer) is semidet.
%  Verbindung mit Hindernis. Tuer hat einen zustand/2.
tuer(korridor,   labor,      labortuer).
tuer(labor,      korridor,   labortuer).
tuer(korridor,   archiv,     archivtuer).
tuer(archiv,     korridor,   archivtuer).
tuer(archiv,     geheimraum, geheimgang).
tuer(geheimraum, archiv,     geheimgang).

%! behaelter(?B) is nondet.
behaelter(schreibtisch).
behaelter(schublade).
behaelter(geheimfach).

%! verwendbar_mit(?Ziel, ?Werkzeug) is nondet.
verwendbar_mit(labortuer,  id_karte).
verwendbar_mit(archivtuer, brecheisen).

%! aktivierbar(?Obj) is semidet.
aktivierbar(taschenlampe).

%! benoetigt_licht(?Raum) is semidet.
benoetigt_licht(geheimraum).

%! wandinschrift(?Raum, ?Zahl) is nondet.
%  Verteilte Zahlenhinweise fuer das Schaltpult-Raetsel (MAZE-Stil).
wandinschrift(eingang,  '3').
wandinschrift(korridor, '7').
wandinschrift(labor,    '1').
wandinschrift(archiv,   '4').

%! aktenordner(?Nr) is nondet.
%  Die vier Ordner im Regal, die gezogen werden muessen.
aktenordner('7').
aktenordner('11').
aktenordner('13').
aktenordner('17').

%! regal_loesung(?Reihenfolge) is det.
%  Korrekte Zugfolge fuer das Kombinationsraetsel am Regal.
%  Codiert durch italienisches Kartenspiel Scopa:
%    Keule(Bastoni)=17, Kelch(Coppe)=13, Muenze(Denari)=7, Schwert(Spade)=11
%  Rangfolge: Bastoni > Coppe > Denari > Spade
regal_loesung(['17', '13', '7', '11']).

%! schaltpult_loesung(?Loesung) is det.
%  Korrekte Winkelkombination fuer das Steuerpult-Raetsel.
%  Die acht Planeten-Schalter in Grad: Sonne in der Mitte, Planeten nach der Notiz.
schaltpult_loesung('180 135 315 270 90 45 0 180').

% =============================================================================
%  DYNAMISCHER SPIELZUSTAND
% =============================================================================

:- dynamic(position/2).     % position(Entitaet, Ort)
:- dynamic(inventar/2).     % inventar(Spielfigur, Gegenstand)
:- dynamic(zustand/2).      % zustand(Entitaet, Zustand)  -- incl. zustand(Obj, aktiv)
:- dynamic(besucht/2).      % besucht(Spielfigur, Raumliste)
:- dynamic(gelesen/2).      % gelesen(Spielfigur, Obj)
:- dynamic(gezogen/1).      % gezogen(Ordner-Nr) -- Regalraetsel
:- dynamic(stop/0).

% =============================================================================
%  INITIALISIERUNG
% =============================================================================

%! init is det.
init :-
    retractall(position(_, _)),
    retractall(inventar(_, _)),
    retractall(zustand(_, _)),
    retractall(besucht(_, _)),
    retractall(gelesen(_, _)),
    retractall(gezogen(_)),
    retractall(stop),
    % Spielfigur
    assertz(position(ich, eingang)),
    % Gegenstaende
    assertz(position(brecheisen,   eingang)),
    assertz(position(id_karte,     korridor)),
    assertz(position(taschenlampe, labor)),
    assertz(position(buch,         schublade)),
    assertz(position(akte,         geheimfach)),
    % Behaelter-Hierarchie
    assertz(position(schublade,    schreibtisch)),
    assertz(position(schreibtisch, korridor)),
    assertz(position(geheimfach,   geheimraum)),
    % Fest installierte Objekte
    assertz(position(schaltpult,   labor)),
    assertz(position(notiz,        schaltpult)),
    assertz(position(regal,        archiv)),
    % Tuer- und Verbindungszustaende
    assertz(zustand(labortuer,     verschlossen)),
    assertz(zustand(archivtuer,    verschlossen)),
    assertz(zustand(geheimgang,    verschlossen)),
    assertz(zustand(geheimfach,    verborgen)),
    assertz(zustand(schaltpult,    gesperrt)),
    assertz(besucht(ich, [eingang])).

% =============================================================================
%  DARSTELLUNG
% =============================================================================

%! trennlinie is det.
%  Gibt eine visuelle Trennlinie aus.
trennlinie :- format("------------------------------------------------------------~n", []).

%! schreibe_text(+Text) is det.
%  Gibt einen beschreibung-Text korrekt aus.
%  In Scryer sind "-Strings Zeichenlisten; format("~s") gibt sie direkt aus.
schreibe_text(Text) :-
    format("~s", [Text]), nl.

%! sichtbare_umgebung is det.
sichtbare_umgebung :-
    cls,
    position(ich, aussen), !,
    catch(lies_textdatei('end.txt'), _,
          format("Du bist aussen.~n", [])).
sichtbare_umgebung :-
    position(ich, Raum),
    benoetigt_licht(Raum),
    \+ zustand(taschenlampe, aktiv), !,
    trennlinie,
    format("  ~w~n", [Raum]),
    trennlinie,
    nl,
    zeige_geheimraum_text.
sichtbare_umgebung :-
    position(ich, Raum),
    trennlinie,
    format("  ~w~n", [Raum]),
    trennlinie,
    nl,
    (   beschreibung(Raum, Text)
    ->  schreibe_text(Text), nl
    ;   true
    ),
    findall(G, (position(G, Raum), gegenstand(G)), Gs),
    (   Gs \= []
    ->  format("Du siehst:~n", []),
        forall(member(G, Gs), format("  ~w~n", [G])),
        nl
    ;   true
    ),
    format("Ausgaenge:~n", []),
    forall(
        verbindet(Raum, Nachbar),
        format(" ~w~n", [Nachbar])
    ),
    tuer_anzeigen(Raum),
    nl.

%! zeige_geheimraum_text is det.
%  Gibt den kontextabhaengigen Geheimraum-Text aus (drei Zustaende).
zeige_geheimraum_text :-
    gelesen(ich, akte), !,
    catch(lies_textdatei('geheimraum_meta.txt'), _,
          format("Stille. Der Raum wartet.~n", [])).
zeige_geheimraum_text :-
    inventar(ich, akte), !,
    catch(lies_textdatei('geheimraum_beleuchtet.txt'), _,
          format("Der Geheimraum. Die Taschenlampe wirft lange Schatten.~n", [])).
zeige_geheimraum_text :-
    catch(lies_textdatei('geheimraum.txt'), _,
          format("Pechschwarze Dunkelheit. Du kannst nichts erkennen.~n", [])).

%! tuer_anzeigen(+Raum) is det.
tuer_anzeigen(Raum) :-
    forall(
        (   tuer(Raum, Nachbar, Tuer),
            (   Tuer == geheimgang
            ->  zustand(regal, verschoben)
            ;   \+ zustand(Tuer, verborgen)
            )
        ),
        format(" ~w~n", [Nachbar])
    ).

%! in_inventar is det.
in_inventar :-
    findall(G, inventar(ich, G), Gs),
    sort(Gs, Sortiert),
    findall(A, zustand(A, aktiv), Aktiv),
    (   Sortiert \= []
    ->  format("Du trägst beir dir:~n", []),
        forall(member(G, Sortiert), format("  ~w~n", [G]))
    ;   format("Dein Inventar ist leer.~n", [])
    ),
    (   Aktiv \= []
    ->  format("Aktiviert:~n", []),
        forall(member(A, Aktiv), format("  ~w~n", [A]))
    ;   true
    ).

%! hilfe_text is det.
hilfe_text :- lies_textdatei('hilfe.txt').

% =============================================================================
%  ERREICHBARKEIT (transitiv)
% =============================================================================

%! erreichbar(+Obj, +Raum) is semidet.
erreichbar(Obj, Raum) :-
    position(Obj, Raum),
    raum(Raum).
erreichbar(Obj, Raum) :-
    position(Obj, Behaelter),
    \+ zustand(Behaelter, verborgen),
    erreichbar(Behaelter, Raum).

% =============================================================================
%  AKTIONEN (STRIPS-Modell)
%
%  Jede Aktion folgt dem Schema:
%    pre(a): Vorbedingungen im Regelrumpf
%    del(a): retract entfernt alten Zustand
%    add(a): assertz schreibt neuen Zustand
% =============================================================================

%! gehe_nach(+NeuerRaum) is det.
gehe_nach(NeuerRaum) :-
    position(ich, AktuellerRaum),
    verbindet(AktuellerRaum, NeuerRaum),
    \+ tuer(AktuellerRaum, NeuerRaum, _), !,
    retract(position(ich, AktuellerRaum)),
    assertz(position(ich, NeuerRaum)),
    raum_betreten(ich, NeuerRaum),
    sichtbare_umgebung.
gehe_nach(NeuerRaum) :-
    position(ich, AktuellerRaum),
    tuer(AktuellerRaum, NeuerRaum, Tuer),
    zustand(Tuer, offen), !,
    retract(position(ich, AktuellerRaum)),
    assertz(position(ich, NeuerRaum)),
    raum_betreten(ich, NeuerRaum),
    sichtbare_umgebung.
gehe_nach(NeuerRaum) :-
    position(ich, AktuellerRaum),
    tuer(AktuellerRaum, NeuerRaum, Tuer),
    zustand(Tuer, verschlossen),
    verwendbar_mit(Tuer, _Werkzeug), !,
    format("Die ~w ist verschlossen.~n", [Tuer]).
gehe_nach(NeuerRaum) :-
    position(ich, AktuellerRaum),
    tuer(AktuellerRaum, NeuerRaum, geheimgang),
    \+ zustand(regal, verschoben), !,
    format("Das Regal versperrt den Weg. Es muss erst zur Seite geschoben werden.~n", []).
gehe_nach(NeuerRaum) :-
    position(ich, AktuellerRaum),
    tuer(AktuellerRaum, NeuerRaum, Tuer),
    zustand(Tuer, verschlossen), !,
    format("Die ~w ist verschlossen. Du hast keine Moeglichkeit, sie zu oeffnen.~n", [Tuer]).
gehe_nach(NeuerRaum) :-
    position(ich, AktuellerRaum),
    tuer(AktuellerRaum, NeuerRaum, Tuer),
    zustand(Tuer, verborgen), !,
    format("Dorthin fuehrt kein Weg von hier.~n", []).
gehe_nach(_) :-
    format("Dorthin fuehrt kein Weg von hier.~n", []).

%! nimm(+Gegenstand) is det.
%  pre(a): gegenstand(G), erreichbar(G, Raum)
%  del(a): position(G, Ort)
%  add(a): inventar(ich, G)
nimm(Gegenstand) :-
    gegenstand(Gegenstand),
    position(ich, Raum),
    erreichbar(Gegenstand, Raum),
    position(Gegenstand, Ort), !,
    retract(position(Gegenstand, Ort)),
    assertz(inventar(ich, Gegenstand)),
    format("Du nimmst ~w.~n", [Gegenstand]).
nimm(Gegenstand) :-
    format("~w liegt hier nicht.~n", [Gegenstand]).

%! lege_ab(+Gegenstand) is det.
lege_ab(Gegenstand) :-
    inventar(ich, Gegenstand), !,
    retract(inventar(ich, Gegenstand)),
    position(ich, Raum),
    assertz(position(Gegenstand, Raum)),
    format("Du legst ~w hier ab.~n", [Gegenstand]).
lege_ab(Gegenstand) :-
    format("~w traegst du nicht.~n", [Gegenstand]).

%! oeffne(+Tuer) is det.
oeffne(Tuer) :-
    position(ich, Raum),
    \+ tuer(Raum, _, Tuer), !,
    format("~w ist von hier nicht erreichbar.~n", [Tuer]).
oeffne(Tuer) :-
    \+ zustand(Tuer, verschlossen), !,
    format("~w ist bereits offen.~n", [Tuer]).
oeffne(Tuer) :-
    kann_oeffnen(Tuer), !,
    retract(zustand(Tuer, verschlossen)),
    assertz(zustand(Tuer, offen)),
    format("Du oeffnest ~w.~n", [Tuer]).
oeffne(Tuer) :-
    verwendbar_mit(Tuer, _Werkzeug), !,
    format("Du kannst ~w nicht oeffnen.~n", [Tuer]).
oeffne(Tuer) :-
    format("Du kannst ~w nicht oeffnen.~n", [Tuer]).

%! verwende(+Werkzeug, +Ziel) is det.
verwende(Werkzeug, _) :-
    \+ inventar(ich, Werkzeug), !,
    format("~w traegst du nicht.~n", [Werkzeug]).
verwende(Werkzeug, Ziel) :-
    verwendbar_mit(Ziel, Werkzeug),
    zustand(Ziel, verschlossen), !,
    retract(zustand(Ziel, verschlossen)),
    assertz(zustand(Ziel, offen)),
    format("Du benutzt ~w an ~w. Es oeffnet sich.~n", [Werkzeug, Ziel]).
verwende(_, Ziel) :-
    verwendbar_mit(Ziel, _),
    \+ zustand(Ziel, verschlossen), !,
    format("~w ist bereits offen.~n", [Ziel]).
verwende(Werkzeug, Ziel) :-
    format("~w laesst sich nicht mit ~w verwenden.~n", [Ziel, Werkzeug]).

%! aktiviere(+Obj) is det.
%  pre(a): inventar(ich, Obj), aktivierbar(Obj)
%  add(a): zustand(Obj, aktiv)
aktiviere(Obj) :-
    \+ inventar(ich, Obj), !,
    format("~w traegst du nicht.~n", [Obj]).
aktiviere(Obj) :-
    zustand(Obj, aktiv), !,
    format("~w ist bereits aktiviert.~n", [Obj]).
aktiviere(taschenlampe) :-
    assertz(zustand(taschenlampe, aktiv)),
    format("Du aktivierst taschenlampe.~n", []),
    (   position(ich, geheimraum)
    ->  format("Der Lichtkegel erleuchtet den Raum. Der Boden wird sichtbar.~n", []),
        sichtbare_umgebung
    ;   true
    ).
aktiviere(Obj) :-
    aktivierbar(Obj), !,
    assertz(zustand(Obj, aktiv)),
    format("Du aktivierst ~w.~n", [Obj]).
aktiviere(Obj) :-
    format("~w laesst sich nicht aktivieren.~n", [Obj]).

%! kann_oeffnen(?Tuer) is semidet.
kann_oeffnen(Tuer) :-
    zustand(Tuer, verschlossen),
    verwendbar_mit(Tuer, Werkzeug),
    inventar(ich, Werkzeug).

%! raum_betreten(+Spielfigur, +Raum) is det.
raum_betreten(Spielfigur, Raum) :-
    besucht(Spielfigur, Bisher),
    (   member(Raum, Bisher)
    ->  true
    ;   append(Bisher, [Raum], Neu),
        retract(besucht(Spielfigur, Bisher)),
        assertz(besucht(Spielfigur, Neu))
    ).

% =============================================================================
%  REGALRAETSEL
%  Kombinationsraetsel: vier Aktenordner in der richtigen Reihenfolge ziehen.
%  Codierung: Rangfolge Scopa-Karten (Bastoni > Coppe > Denari > Spade)
%    17=Bastoni(Keule), 13=Coppe(Kelch), 7=Denari(Muenze), 11=Spade(Schwert)
%  Loesung: 17, 13, 7, 11
%  Kann Ausgebaut werden zu zufälliger Zuweisung pro Neustart 
% =============================================================================

%! entferne_ordner(+Nr) is det.
entferne_ordner(_) :-
    \+ position(ich, archiv), !,
    format("Hier gibt es kein Regal.~n", []).
entferne_ordner(Nr) :-
    \+ aktenordner(Nr), !,
    format("Ordner ~w ist nichts Besonderes. Er ist voller vergilbter Akten. ~n", [Nr]).
entferne_ordner(Nr) :-
    gezogen(Nr), !,
    format("Aktenordner ~w hast du bereits gezogen.~n", [Nr]).
entferne_ordner(Nr) :-
    assertz(gezogen(Nr)),
    findall(G, gezogen(G), Gezogen),
    regal_loesung(Loesung),
    length(Gezogen, Len),
    length(Praefix, Len),
    append(Praefix, _, Loesung),
    (   Praefix == Gezogen
    ->  (   Gezogen == Loesung
        ->  regal_geloest
        ;   format("Klick. Der Ordner ~w sitzt locker.~n", [Nr])
        )
    ;   retractall(gezogen(_)),
        format("Ein leises Knacken. Die Ordner schnappen zurueck.~n", []),
        format("Stille. Es passiert nichts. Du stellst die Buecher zurueck.~n", [])
    ).

%! regal_geloest is det.
%  pre(a): zustand(geheimgang, entsperrt)
%  del(a): zustand(geheimgang, entsperrt)
%  add(a): zustand(geheimgang, offen)
regal_geloest :-
    format("~nEin schweres Knirschen. Das Regal gleitet langsam zur Seite.~n", []),
    format("Dahinter: eine schwere Tuer mit einem Kartenleser.~n", []),
    assertz(zustand(regal, verschoben)).

% =============================================================================
%  SCHALTPULT-RAETSEL (WINKELPUZZLE)
%  Acht kreisförmige Regler (Symbole: ☉ ☿ ♀ ♁ ♂ ♃ ♄ ♅ ♆) müssen in die
%  richtigen Winkelpositionen gebracht werden. Der letzte Regler in der Mitte
%  gibt die Konstellation frei.
%  Der Spieler gibt alle acht Winkel als String ein:
%    einstellen 180 135 315 270 90 45 0 180
% =============================================================================

%! winkel_eingabe(+Angles) is det.
winkel_eingabe(_) :-
    \+ position(ich, labor), !,
    format("Hier gibt es kein Schaltpult.~n", []).
winkel_eingabe(Angles) :-
    schaltpult_loesung(Loesung),
    (   Angles == Loesung
    ->  (   \+ zustand(regal, verschoben)
        ->  format("Ein entfernter Mechanismus ist zu hoeren.~n", []),
            format("Ein positives Signal ertoent aus dem Steuerpult.~n", []),
            format("Doch das Ziel wird noch durch das Regal versperrt.~n", [])
        ;   zustand(geheimgang, verschlossen)
        ->  format("Ein entfernter Mechanismus ist zu hoeren.~n", []),
            format("Ein positives Signal ertoent aus dem Steuerpult.~n", []),
            retract(zustand(geheimgang, verschlossen)),
            assertz(zustand(geheimgang, offen))
        ;   format("Die Tuer ist bereits offen.~n", [])
        )
    ;   format("Ein Fehlerton ertoent aus dem Steuerpult.~n", [])
    ).

% =============================================================================
%  SPIELZIEL UND METARAETSEL
% =============================================================================

%! akte_gelesen is semidet.
akte_gelesen :- gelesen(ich, akte).

%! geheimgang_verschliessen is det.
%  Wird aufgerufen wenn die Akte gelesen wurde.
geheimgang_verschliessen :-
    (   zustand(geheimgang, offen)
    ->  retract(zustand(geheimgang, offen)),
        assertz(zustand(geheimgang, verschlossen))
    ;   true
    ).

%! entkommen(+Metacode) is det.
%  Das Metaraetsel: Der vom Spieler eingegebene Prolog-Code wird tatsaechlich
%  per call/1 ausgefuehrt -- die Spielwelt wird durch Metapraedikate umprogrammiert.
%
%  HINWEIS (Code-Injektion): Hier wird Nutzereingabe bewusst als ausfuehrbarer
%  Prolog-Code behandelt. Das ist der Lehr-Gag: der Spieler schreibt Prolog,
%  das das laufende Programm veraendert. In produktiven Systemen niemals
%  Nutzereingaben direkt per call/1 ausfuehren.
entkommen(_) :-
    \+ akte_gelesen, !,
    format("Ich hab nicht genug wissen. Ich muss die Akte lesen.~n", []).
entkommen(_) :-
    \+ position(ich, geheimraum), !,
    format("Das funktioniert hier nicht. Du spürst, dass du am falschen Ort bist.~n", []).
entkommen(Metacode) :-
    % STRIPS (durch den vom Spieler eingegebenen Code):
    % pre:  akte gelesen, position(ich, geheimraum)
    % del/add: via call(Term)
    atom_chars(Metacode, Cs),
    append(Cs, ['.'], CsDot),
    read_term_from_chars(CsDot, Term, []),
    format("~nDu sprichst die Worte. Der Raum verformt sich.~n~n", []),
    format("  ~w~n~n", [Metacode]),
    sleep(2),
    call(Term),    % <-- Metapraedikat: Spieler-Code wird tatsaechlich ausgefuehrt
    assertz(stop),
    zeige_ende,
    neustarten_menue.

%! Metacode_korrekt(+Metacode) is semidet.
%  Der erwartete Metacode des Metaraetsels (ohne Abschlusszeichen).
metacode_korrekt('retract(position(ich,_)),assertz(position(ich,aussen))').

%! sage_metatext(+MetacodeRoh) is det.
%  Prueft den eingegebenen Metacode gegen metacode_korrekt/1 und
%  fuehrt ihn bei Uebereinstimmung tatsaechlich per call/1 aus.
sage_metatext(MetacodeRoh) :-
    atom_chars(MetacodeRoh, Cs),
    entferne_abschluss(Cs, Bs),
    atom_chars(Metacode, Bs),
    atom_chars(Metacode, CodeChars),
    exkludiere_leerzeichen(CodeChars, Normalisiert),
    atom_chars(NormCode, Normalisiert),
    metacode_korrekt(NormCode), !,
    entkommen(Metacode).
sage_metatext(_) :-
    format("Deine Worte verhallen in den Gängen der Einrichtung.~n", []).

% =============================================================================
%  BETRACHTEN
% =============================================================================

%! betrachte(+Obj) is det.
betrachte(akte) :-
    inventar(ich, akte), !,
    (   \+ akte_gelesen
    ->  assertz(gelesen(ich, akte)),
        geheimgang_verschliessen,
        format("~n[Die Tueren fallen ins Schloss.]~n~n", [])
    ;   true
    ),
    lies_textdatei('akte.txt').
betrachte(akte) :-
    beschreibung(akte, Text),
    schreibe_text(Text),
    format("Du musst sie erst nehmen.~n", []).
betrachte(regal) :-
    position(ich, archiv),
    gelesen(ich, buch),
    zustand(regal, verschoben), !,
    format("Das Regal: eine schwere Tuer ist dahinter sichtbar.~n", []).
betrachte(regal) :-
    position(ich, archiv),
    gelesen(ich, buch), !,
    format("Das Regal. Du denkst an das Buch und die Symbole auf den Ordnerrucken.~n", []).
betrachte(regal) :-
    position(ich, archiv), !,
    beschreibung(regal, Text),
    schreibe_text(Text).
betrachte(boden) :-
    position(ich, geheimraum),
    zustand(taschenlampe, aktiv), !,
    format("Der Boden knarrt ungleichmaessig. Eine Diele sitzt erkennbar locker.~n", []).
betrachte(boden) :-
    position(ich, geheimraum), !,
    format("Es ist zu dunkel, um den Boden zu erkennen. Licht wuerde helfen.~n", []).
betrachte(wand) :-
    position(ich, Raum),
    wandinschrift(Raum, Zahl), !,
    format("An der Wand: ~w~n", [Zahl]).
betrachte(wand) :-
    beschreibung(wand, Text),
    schreibe_text(Text).
betrachte(boden) :-
    beschreibung(boden, Text),
    schreibe_text(Text).
betrachte(Obj) :-
    (inventar(ich, Obj) ; position(ich, Raum), erreichbar(Obj, Raum)),
    beschreibung(Obj, Text), !,
    schreibe_text(Text).
betrachte(Obj) :-
    format("Du siehst hier kein ~w.~n", [Obj]).

% =============================================================================
%  UNTERSUCHEN
% =============================================================================

%! untersuche(+Obj) is det.
untersuche(wand) :-
    position(ich, Raum),
    wandinschrift(Raum, Zahl), !,
    format("An der Wand: ~w~n", [Zahl]).
untersuche(wand) :-
    beschreibung(wand, Text),
    schreibe_text(Text).
untersuche(regal) :-
    position(ich, archiv),
    gelesen(ich, buch),
    zustand(regal, verschoben), !,
    lies_textdatei('regal.txt'),
    (   zustand(geheimgang, verschlossen)
    ->  format("~nDie Tuer ist noch verschlossen. Das Schaltpult im Labor koennte helfen.~n", [])
    ;   true
    ).
untersuche(regal) :-
    position(ich, archiv),
    gelesen(ich, buch),
    \+ zustand(regal, verschoben), !,
    format("Das Regal. Die Ordner haben Zahlen auf dem Ruecken.~n", []),
    format("Ziehe die Ordner in der richtigen Reihenfolge mit: entferne <nr>~n", []).
untersuche(regal) :-
    position(ich, archiv), !,
    beschreibung(regal, Text),
    schreibe_text(Text),
    format("Vielleicht sagt dir das Buch mehr darueber.~n", []).
untersuche(boden) :-
    position(ich, geheimraum),
    \+ zustand(taschenlampe, aktiv), !,
    format("Es ist zu dunkel, um den Boden zu erkennen. Licht wuerde helfen.~n", []).
untersuche(boden) :-
    position(ich, geheimraum),
    zustand(geheimfach, verborgen), !,
    format("Eine lose Diele. Darunter: ein Hohlraum. Ein Geheimfach!~n", []),
    retract(zustand(geheimfach, verborgen)),
    assertz(zustand(geheimfach, entdeckt)).
untersuche(boden) :-
    position(ich, geheimraum), !,
    format("Die lose Diele. Das Geheimfach liegt offen.~n", []).
untersuche(boden) :-
    beschreibung(boden, Text),
    schreibe_text(Text).
untersuche(schaltpult) :-
    position(ich, labor), !,
    lies_textdatei('steuerpult.txt').
untersuche(schaltpult) :-
    format("Hier gibt es kein Schaltpult.~n", []).
untersuche(notiz) :-
    position(ich, labor), !,
    lies_textdatei('notiz.txt').
untersuche(notiz) :-
    format("Hier gibt es keine Notiz.~n", []).
untersuche(buch) :-
    (inventar(ich, buch) ; position(ich, Raum), erreichbar(buch, Raum)), !,
    (   \+ gelesen(ich, buch)
    ->  assertz(gelesen(ich, buch))
    ;   true
    ),
    lies_textdatei('buch.txt').
untersuche(Obj) :-
    (inventar(ich, Obj) ; position(ich, Raum), erreichbar(Obj, Raum)),
    atom_concat(Obj, '.txt', Datei),
    catch(lies_textdatei(Datei), _, fail), !.
untersuche(Obj) :-
    (inventar(ich, Obj) ; position(ich, Raum), erreichbar(Obj, Raum)),
    behaelter(Obj), !,
    zeige_inhalt(Obj).
untersuche(Obj) :-
    format("Du findest nichts Besonderes an ~w.~n", [Obj]).

%! zeige_inhalt(+Behaelter) is det.
zeige_inhalt(Behaelter) :-
    findall(I, (position(I, Behaelter), gegenstand(I)), Gs),
    findall(B, (position(B, Behaelter), behaelter(B)), Bs),
    append(Gs, Bs, Inhalt),
    (   Inhalt = []
    ->  format("~w ist leer.~n", [Behaelter])
    ;   format("In ~w siehst du:~n", [Behaelter]),
        forall(member(I, Inhalt), format("  ~w~n", [I]))
    ).

% =============================================================================
%  LESEN
% =============================================================================

%! lese(+Obj) is det.
lese(akte) :-
    (inventar(ich, akte) ; position(ich, Raum), erreichbar(akte, Raum)), !,
    (   \+ akte_gelesen
    ->  assertz(gelesen(ich, akte)),
        geheimgang_verschliessen,
        format("~n[Die Tueren fallen ins Schloss.]~n~n", [])
    ;   true
    ),
    lies_textdatei('akte.txt').
lese(Obj) :-
    (inventar(ich, Obj) ; position(ich, Raum), erreichbar(Obj, Raum)), !,
    (   \+ gelesen(ich, Obj)
    ->  assertz(gelesen(ich, Obj))
    ;   true
    ),
    atom_concat(Obj, '.txt', Datei),
    catch(lies_textdatei(Datei), _,
          (   beschreibung(Obj, Text)
          ->  schreibe_text(Text)
          ;   format("Hier gibt es nichts zu lesen.~n", [])
          )).
lese(Obj) :-
    format("~w liegt nicht in deiner Reichweite.~n", [Obj]).

% =============================================================================
%  BESCHREIBUNGEN
% =============================================================================

%! beschreibung(+Obj, -Text) is semidet.
beschreibung(akte,         "Akte VK-47. Versiegelt. Ein Roter Stempel: STRENG GEHEIM.").
beschreibung(archiv,       "Wandhohe Regale, dicht bestueckt mit nummerierten Aktenordnern. Staub liegt auf allem.").
beschreibung(archivtuer,   "Eine alte Schiebetür aus massivem Holz, sie hängt leicht schief in den Angeln und lässt sich kaum bewegen.").
beschreibung(brecheisen,   "Ein schweres Brecheisen. Nuetzlich gegen schwache Schloesser. Oder Holztüren.").
beschreibung(buch,         "Ein zerlesenes Buch MAZE, voller handschriftlicher Anmerkungen.").
beschreibung(eingang,      "Die Eingangshalle. Der Ort scheint fluchtartig verlassen wirden zu sein.  Ein umgestuerzter Baum versperrt den Ausgang.").
beschreibung(geheimfach,   "Ein Hohlraum unter einer losen Diele.").
beschreibung(geheimgang,   "Eine schwere Tuer hinter dem Regal. Kein Schloss, kein Öffnungsmechanismus. Wird sie von woanders geöffnet?").
beschreibung(geheimraum,   "Ein enger, staubiger Raum. Hier war schon lange niemand mehr. Oder doch?").
beschreibung(id_karte,     "Eine laminierte ID-Karte. Das Foto ist unkenntlich gemacht worden.").
beschreibung(korridor,     "Ein langer Korridor. Die Deckenlampe flackert. Strom scheint es noch zu geben. Irgendwo tropft Wasser.").
beschreibung(labor,        "Ein verlassenes Labor. Mobililar wie aus den 1960ern. Equipment wie aus der Zukunft.").
beschreibung(labortuer,    "Eine Stahltuer mit Kartenleser. ").
beschreibung(regal,        "Ein deckenhohes Regal. Ordnerrucken mit Zahlen und kleinen Symbolen.").
beschreibung(schaltpult,   "Ein altes Schaltpult mit unbekannten Symbolen. Ein Schalterfeld mit Abdrücken im Staub sticht hervor. Es scheinen erst kürzlich benutzt worden zu sein").
beschreibung(notiz,        "Ein Klemmbrett mit einer Notiz. Sie enthält rätselhafte Hinweise zu Winkeln.").
beschreibung(schreibtisch, "Ein kastiger Laborschreibtisch. Er hat eine Schublade.").
beschreibung(schublade,    "Eine halb geöffnete Schublade. Darin liegt ein Buch.").
beschreibung(taschenlampe, "Eine robuste Taschenlampe, die Batterien scheinen noch ok zu sein.").
beschreibung(boden,        "Am Boden ist nichts Besonderes.").
beschreibung(wand,         "Eine ganz normale Wand. Nichts Besonderes.").

% =============================================================================
%  SPIELSTAND-PERSISTENZ (write_term/read_term)
%  Der gesamte Zustand wird als EIN Term serialisiert.
%  Vorteil: Code und Daten bleiben strikt getrennt.
% =============================================================================

%! speichere_spielstand(+Datei) is det.
speichere_spielstand(Datei) :-
    findall(position(E,O),  position(E,O),   Pos),
    findall(inventar(S,G),  inventar(S,G),   Inv),
    findall(zustand(E,Z),   zustand(E,Z),    Zst),
    findall(besucht(S,L),   besucht(S,L),    Bes),
    findall(gelesen(S,O),   gelesen(S,O),    Gel),
    findall(gezogen(N),     gezogen(N),      Gez),
    Zustand = spielstand(Pos,Inv,Zst,Bes,Gel,Gez),
    open(Datei, write, Stream),
    write_term(Stream, Zustand, [quoted(true)]),
    write(Stream, '.'),
    nl(Stream),
    close(Stream),
    format("Spielstand gespeichert in ~w.~n", [Datei]).

%! lade_spielstand(+Datei) is det.
lade_spielstand(Datei) :-
    catch(
        (   open(Datei, read, Stream),
            read_term(Stream, spielstand(Pos,Inv,Zst,Bes,Gel,Gez), []),
            close(Stream),
            retractall(position(_,_)),
            retractall(inventar(_,_)),
            retractall(zustand(_,_)),
            retractall(besucht(_,_)),
            retractall(gelesen(_,_)),
            retractall(gezogen(_)),
            maplist(assertz, Pos),
            maplist(assertz, Inv),
            maplist(assertz, Zst),
            maplist(assertz, Bes),
            maplist(assertz, Gel),
            maplist(assertz, Gez),
            format("Spielstand geladen aus ~w.~n", [Datei]),
            sichtbare_umgebung
        ),
        _,
        format("Kein Spielstand gefunden (~w).~n", [Datei])
    ).

% =============================================================================
%  HILFSPRAEDIKATE
% =============================================================================

% löscht das Terminal
cls :- format("\x1b\[H\x1b\[2J", []).

% catch gibt einen Fehler aus, falls die Datei nicht gefunden wird.
zeige_titelseite :-
    cls,
    catch(lies_textdatei('title.txt'), _, true),
    sleep(5).

zeige_intro :-
    cls,
    catch(lies_textdatei('intro.txt'), _, true),
    format("~n[Drücke Enter um zu beginnen...]~n", []),
    get_line_to_chars(user_input, _, []).

zeige_ende :-
    cls,
    catch(lies_textdatei('end.txt'), _, true),
    format("~n[Drücke Enter fuer Credits...]~n", []),
    get_line_to_chars(user_input, _, []).

zeige_credits :-
    cls,
    catch(lies_textdatei('outro.txt'), _, true),
    format("~n[Drücke Enter zum Beenden...]~n", []),
    get_line_to_chars(user_input, _, []).

%! neustarten_menue is det.
%  Wird nach erfolgreichem Spielende angezeigt.
neustarten_menue :-
    cls,
    format("Spiel neu starten?~n~n", []),
    format("  1. Neues Spiel~n", []),
    format("  2. Beenden~n~n", []),
    format("> ", []),
    get_line_to_chars(user_input, Zeichen, []),
    zeile_zu_woertern(Zeichen, Woerter),
    (   Woerter = ['1'|_]
    ->  play
    ;   Woerter = ['2'|_]
    ->  zeige_credits
    ;   format("Bitte 1 oder 2 eingeben.~n", []),
        neustarten_menue
    ).

%! lies_textdatei(+Dateiname) is det.
lies_textdatei(Dateiname) :-
    open(Dateiname, read, Stream),
    lies_zeilen(Stream),
    close(Stream).

%! lies_zeilen(+Stream) is det.
lies_zeilen(Stream) :-
    (   at_end_of_stream(Stream)
    ->  true
    ;   get_line_to_chars(Stream, Zeichen, []),
        format("~s", [Zeichen]),
        lies_zeilen(Stream)
    ).

% =============================================================================
%  DCG-PARSER
%  Schicht 1: Zeile -> Tokenliste
%  Schicht 2: Tokenliste -> Spielaktion (DCG)
%  Schicht 3: Lesen, Parsen, Fehlerbehandlung
% =============================================================================

zeile_zu_woertern([], []) :- !.
zeile_zu_woertern(Zeichen, Woerter) :-
    leerzeichen_ueberspringen(Zeichen, Rest1),
    (   Rest1 = []
    ->  Woerter = []
    ;   wort_lesen(Rest1, WZ, Rest2),
        atom_chars(Wort, WZ),
        zeile_zu_woertern(Rest2, Weitere),
        Woerter = [Wort|Weitere]
    ).

normalisiere_token(Roh, Norm) :-
    atom_chars(Roh, Zeichen),
    entferne_abschluss(Zeichen, Bereinigt),
    (   Bereinigt = []
    ->  Norm = Roh
    ;   atom_chars(Norm, Bereinigt)
    ).

entferne_abschluss(In, Out) :-
    append(Vorne, [Letztes], In),
    (member(Letztes, ['.', ',', '!', '?']) ; ist_leerzeichen(Letztes)), !,
    entferne_abschluss(Vorne, Out).
entferne_abschluss(In, In).

ist_leerzeichen(' ').
ist_leerzeichen('\t').
ist_leerzeichen('\n').
ist_leerzeichen('\r').

exkludiere_leerzeichen([], []).
exkludiere_leerzeichen([C|Cs], Out) :-
    ist_leerzeichen(C), !,
    exkludiere_leerzeichen(Cs, Out).
exkludiere_leerzeichen([C|Cs], [C|Out]) :-
    exkludiere_leerzeichen(Cs, Out).

leerzeichen_ueberspringen([Z|R], E) :- ist_leerzeichen(Z), !, leerzeichen_ueberspringen(R, E).
leerzeichen_ueberspringen(R, R).

wort_lesen([], [], []) :- !.
wort_lesen([Z|R], [], [Z|R]) :- ist_leerzeichen(Z), !.
wort_lesen([Z|R], [Z|W], E) :- wort_lesen(R, W, E).

%! befehl(-Aktion) is semidet.
befehl(gehe(R))             --> [geh,       R].
befehl(gehe(R))             --> [gehe,      R].
befehl(gehe(R))             --> [gehe,      nach, R].
befehl(betrachte(O))        --> [betrachte, O].
befehl(betrachte(O))        --> [schau,     O, an].
befehl(untersuche(O))       --> [untersuche, O].
befehl(untersuche(O))       --> [u,          O].
befehl(lese(O))             --> [lies,  O].
befehl(lese(O))             --> [lese,  O].
befehl(lese(O))             --> [lies,  die, O].
befehl(lese(O))             --> [lies,  das, O].
befehl(nimm(O))             --> [nimm,  O].
befehl(nimm(O))             --> [nehme, O].
befehl(nimm(O))             --> [nimm,  die, O].
befehl(nimm(O))             --> [nimm,  den, O].
befehl(lege_ab(O))          --> [lege,  ab,  O].
befehl(lege_ab(O))          --> [lege,  O,   ab].
befehl(oeffne(T))           --> [oeffne, T].
befehl(verwende(O, Z))      --> [verwende, O, mit, Z].
befehl(verwende(O, Z))      --> [benutze,  O, mit, Z].
befehl(verwende(O, Z))      --> [benutze,  O, an,  Z].
befehl(aktiviere(O))        --> [aktiviere, O].
befehl(entferne(Nr))        --> [entferne, Nr].
befehl(einstellen_ohne_argument) --> [einstellen].
befehl(umsehen)             --> [umsehen].
befehl(umsehen)             --> [umschauen].
befehl(umsehen)             --> [schau].
befehl(umsehen)             --> [u].
befehl(inventar)            --> [inventar].
befehl(inventar)            --> [i].
befehl(hilfe)               --> [hilfe].
befehl(hilfe)               --> [h].
befehl(ende)                --> [beende].
befehl(ende)                --> [beenden].
befehl(ende)                --> [ende].
befehl(ende)                --> [quit].
befehl(ende)                --> [exit].
befehl(speichern)           --> [speichern].
befehl(speichern)           --> [speichere].
befehl(laden)               --> [laden].
befehl(laden)               --> [lade].

parse_befehl(Woerter, Aktion) :-
    phrase(befehl(Aktion), Woerter).

%! lies_befehl(-Befehl) is det.
lies_befehl(Befehl) :-
    format("~n> ", []),
    get_line_to_chars(user_input, Zeichen, []),
    (   Zeichen == end_of_file
    ->  Befehl = ende
    ;   at_end_of_stream(user_input), Zeichen == []
    ->  Befehl = ende
    ;   atom_chars(Zeile, Zeichen),
        (   atom_concat('einstellen ', WinkelString, Zeile)
        ->  Befehl = winkel_eingabe(WinkelString)
        ;   atom_concat('sage ', Metacode, Zeile)
        ->  Befehl = sage(Metacode)
        ;   zeile_zu_woertern(Zeichen, Woerter),
            maplist(normalisiere_token, Woerter, Norm),
            (   parse_befehl(Norm, Befehl)
            ->  true
            ;   format("Das habe ich nicht verstanden. Tippe hilfe fuer Befehle.~n", []),
                Befehl = unbekannt
            )
        )
    ).

% =============================================================================
%  DISPATCH
% =============================================================================
% Aus Gründen der Einfachheit sind I/O (format) und Logik hier nicht 100% 
% getrennt. In groesseren Projekten ist es besser, dass die  Aktionen
% Ergebnisterme zurueck geben und der Dispatcher sie ausgibt.

%! dispatch(+Befehl) is det.
dispatch(betrachte(O))      :- betrachte(O).
dispatch(untersuche(O))     :- untersuche(O).
dispatch(lese(O))           :- lese(O).
dispatch(gehe(R))           :- gehe_nach(R).
dispatch(nimm(O))           :- nimm(O).
dispatch(lege_ab(O))        :- lege_ab(O).
dispatch(oeffne(T))         :- oeffne(T).
dispatch(verwende(O, Z))    :- verwende(O, Z).
dispatch(aktiviere(O))      :- aktiviere(O).
dispatch(entferne(Nr))              :- entferne_ordner(Nr).
dispatch(einstellen_ohne_argument)  :-
    format("Gib die Winkel an: einstellen <winkel1 winkel2 ...>~n", []).
dispatch(winkel_eingabe(S))         :- winkel_eingabe(S).
dispatch(sage(P))           :- sage_metatext(P).
dispatch(umsehen)           :- sichtbare_umgebung.
dispatch(inventar)          :- in_inventar.
dispatch(hilfe)             :- hilfe_text.
dispatch(speichern)         :- speichere_spielstand('spielstand.pl').
dispatch(laden)             :- lade_spielstand('spielstand.pl').
dispatch(ende)              :- assertz(stop), format("Auf Wiedersehen.~n", []), zeige_credits.
dispatch(unbekannt).

% =============================================================================
%  GAME LOOP
% =============================================================================

%! play is det.
play :-
    init,
    zeige_titelseite,
    zeige_intro,
    cls,
    sichtbare_umgebung,
    loop_rekursiv.

%! loop_rekursiv is det.
loop_rekursiv :-
    (   stop
    ->  true
    ;   lies_befehl(Befehl),
        dispatch(Befehl),
        loop_rekursiv
    ).
