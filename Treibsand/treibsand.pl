% -- Treibsand --------------------------------------------------------------- %
% Ein Interact Fiction Spiel geschrieben in Prolog während des Kurses
% Logische Labyrinthe an der HSD PBSA, Düsseldorf.
%
% Autor:in : [Eure Namen]
% Datum: [Datum]
% Beschreibung: [Kurze Beschreibung des Spiels]
%
% =============================================================================
% HINWEISE FÜR DIE SEMESTERARBEIT
% =============================================================================
%  "%!" markiert eine Praedikatsdokumentation.
%  "raum" ist der Praedikatsname.
%  "is det" ist die Determinismus-Angabe.
%
%  Die wichtigsten Determinismus-Typen:
%  det:       genau eine Loesung, kein Backtracking-Erfolg danach.
%  semidet:   entweder eine Loesung oder gar keine.
%  nondet:    mehrere Loesungen moeglich.
%  multi:     mindestens eine Loesung, eventuell mehrere.
%
% =============================================================================
% ZU BEANTWORTENDE FRAGEN FÜR DIE SEMESTERARBEIT
% =============================================================================
% Versucht die folgenden Fragen in eurer Dokumentation/Präsentation in euren 
% Worten zu beantworten.
%
% Enthaltene IF-Aspekte:
%
% Enthaltene Logik-Aspekte:
%
% Enthaltene Prolog-Aspekte:


% =============================================================================
% PROLOG MODULE UND EINSTELLUNGEN
% =============================================================================
% Benötigte Module und Scryer Prolog spezifische Einstellungen einbinden.


% =============================================================================     
%  STATISCHES WELTMODELL
% =============================================================================
% Was existiert in der Welt, z.B. Räume, Gegenstände, Charaktere, etc.


% =============================================================================
%  DYNAMISCHES SPIELZUSTAND 
% =============================================================================
% Dynamischen Prädikate definieren.

% =============================================================================   
%  ERREICHBARKEIT
% =============================================================================   
% Prädikate, um die Erreichbarkeit von Räumen zu bestimmen.


% =============================================================================   
%  AKTIONEN (nach Stanford STRIPS-Modell)
%
%  STRIPS (Stanford Research Institute Problem Solver) ist ein allgemeines
%  (nicht Prolog-spezifisches)KI-Planungsmodell (nicht Prolog-spezifisch). 
%  Es taucht in Robotik, Game-AI und Planungssprachen auf. In Prolog wird es 
%  idiomatisch mit retract (del) und assertz (add) umgesetzt.
%
%  Jede Aktion folgt dem Schema:
%    pre(a): Vorbedingungen im Regelrumpf
%    del(a): retract entfernt alten Zustand
%    add(a): assertz schreibt neuen Zustand
% =============================================================================   


% =============================================================================
%  INITIALISIERNG
% =============================================================================
% % Retract aller dynamischen Prädikate, für einen sauberen Spielstart.
% Anfangszustand der dynamsichen Prädikate, aktuelle Position, Inventar, usw.


% =============================================================================   
%  DARSTELLUNG
% =============================================================================   
% Prädikate zur Ausgabe von Räumen, Gegenständen, Charakteren, im Terminal.


% =============================================================================   
%  SPIELZIEL
% =============================================================================   
% Prädikate, die überprüfen, ob das Spielziel erreicht wurde.


% =============================================================================   
%  DCG-PARSER FUER NATUERLICHSPRACHLICHE EINGABE
%
%  Schicht 1: Eingabezeile -> Atomliste (Tokenisierung)
%  Schicht 2: Atomliste -> Spielaktion (DCG-Grammatik)
%  Schicht 3: Eingabe lesen, parsen, Fehler abfangen
% =============================================================================   
% DCG-Grammatik für die natürlichsprachliche Eingabe, z.B. "nimm Schlüssel".


% =============================================================================   
%  DISPATCH
% =============================================================================   
% Prädikate, die die geparste Spielaktion auf Aktionsprädikate verteilen.

% =============================================================================   
%  BESCHREIBUNGEN
% =============================================================================   
% Prädikate, die Kurzbeschreibung von Räumen, Gegenständen, etc. zurückgeben. 


% =============================================================================     
%  HILFSPRAEDIKATE
% =============================================================================
% Prädikate zum löschen des Bildschirms, Einlesen und Ausgabe von Texten, etc.
% Textdateien enthalten die langen Beschreibungen von Räumen, Gegenständen und
% werden zur Laufzeit eingelesen und ausgegeben. 


% =============================================================================   
%  GAME LOOP
% =============================================================================
% Der Hauptspielzyklus, der die Eingabe liest, parst, Aktionen ausführt, 
% bis das Spielziel erreicht ist oder der Spieler das Spiel verlässt.