:- use_module(library(lists)).
:- use_module(library(between)).

% cls is det.
cls :- format("\x1b\[H\x1b\[2J", []).

% Einfache Raum Ausgänge Relation.
% Das ist bei der Listen Variante schwieriger, da man die Liste erst auslesen, 
% modifizieren und dann wieder zurückschreiben müsste.
% Die Räume und Verbindung bilden einen gerichteten Graphen.
% room(1).
% room(2).
% room(3).
% ...

% known_room/1 prüft, ob eine Zahl einen bekannten (nummerierten) Raum bezeichnet.
% unnamed ist kein bekannter Raum.
% 0 und 46+ ebenfalls nicht – nur 1–45 sind es.
% Die var/integer-Guards verhindern Type-Errors durch between/3
% bei nicht-numerischen Atomen wie unnamed.
% known_room(?N) is semidet.
known_room(N) :-
    (var(N) ; integer(N)),
    between(1, 45, N). 

% has_exit(?CurrentRoom, ?ExitToRoom) is nondet.
has_exit(1,20).
has_exit(1,21).
has_exit(1,26).
has_exit(1,41).

has_exit(2,12).
has_exit(2,22).
has_exit(2,29).

has_exit(3,9).
has_exit(3,18).
has_exit(3,33).
has_exit(3,unnamed). % 15

has_exit(4,11).
has_exit(4,15).
has_exit(4,16).
has_exit(4,24).
has_exit(4,29).
has_exit(4,43).
has_exit(4,44).
has_exit(4,unnamed). % 39 
has_exit(4,unnamed). % 42

has_exit(5,20).
has_exit(5,22).
has_exit(5,30).
has_exit(5,43).

has_exit(6,40).
has_exit(6,unnamed). % 8
has_exit(6,unnamed). % 17
has_exit(6,unnamed). % 32

has_exit(7,16).
has_exit(7,33).
has_exit(7,36).

has_exit(8,6).
has_exit(8,12).
has_exit(8,29).
has_exit(8,31).
has_exit(8,unnamed). % 23

has_exit(9,3).
has_exit(9,18).
has_exit(9,unnamed). % 27

has_exit(10,14).
has_exit(10,34).
has_exit(10,41).
has_exit(10,unnamed). % 37

has_exit(11,24).
has_exit(11,40).
has_exit(11,unnamed). % 4
has_exit(11,unnamed). % 19
has_exit(11,unnamed). % 32
has_exit(11,unnamed). % 39

has_exit(12,2).
has_exit(12,8).
has_exit(12,21).
has_exit(12,39).

has_exit(13,18).
has_exit(13,25).
has_exit(13,27).

has_exit(14,10).
has_exit(14,24).
has_exit(14,43).

has_exit(15,3).
has_exit(15,30).
has_exit(15,37).
has_exit(15,unnamed). % 4

has_exit(16,7).
has_exit(16,36).
has_exit(16,unnamed). % 4
has_exit(16,unnamed). % 32

has_exit(17,6).
has_exit(17,33).
has_exit(17,45).
has_exit(17,unnamed). % 29

has_exit(18,3).
has_exit(18,13).
has_exit(18,unnamed). % 9
has_exit(18,unnamed). % 44

has_exit(19,11).
has_exit(19,31).
has_exit(19,unnamed). % 23
has_exit(19,unnamed). % 45

has_exit(20,1).
has_exit(20,5).
has_exit(20,27).
has_exit(20,unnamed). % 37

has_exit(21,24).
has_exit(21,31).
has_exit(21,44).
has_exit(21,unnamed). % 1
has_exit(21,unnamed). % 12

has_exit(22,38).
has_exit(22,43).
has_exit(22,unnamed). % 2
has_exit(22,unnamed). % 5
has_exit(22,unnamed). % 42

has_exit(23,8).
has_exit(23,19).
has_exit(23,28).
has_exit(23,45).

% Raum 24 ist eine Falle: hat nur Eingänge, keine Ausgänge.
% Wir definieren hier nur Räume MIT Ausgängen, daher kein 
% Eintrag in der Datenbasis.
% http://www.intotheabyss.net/room-24/

has_exit(25,13).
has_exit(25,34).
has_exit(25,35).
has_exit(25,unnamed). % 42

has_exit(26,1).
has_exit(26,30).
has_exit(26,36).
has_exit(26,38).

has_exit(27,9).
has_exit(27,13).
has_exit(27,unnamed). % 20

has_exit(28,23).
has_exit(28,32).
has_exit(28,43).
has_exit(28,45).

has_exit(29,2).
has_exit(29,8).
has_exit(29,17).
has_exit(29,35).
has_exit(29,40).
has_exit(29,unnamed). % 4
    
has_exit(30,5).
has_exit(30,15).
has_exit(30,34).
has_exit(30,42).
has_exit(30,unnamed). %26

has_exit(31,19).
has_exit(31,21).
has_exit(31,44).
has_exit(31,unnamed). % 8

has_exit(32,6).
has_exit(32,11).
has_exit(32,16).
has_exit(32,28).

has_exit(33,3).
has_exit(33,7).
has_exit(33,35).
has_exit(33,unnamed). % 17

has_exit(34,10).
has_exit(34,25).
has_exit(34,unnamed). % 30

has_exit(35,33).
has_exit(35,unnamed). % 25
has_exit(35,unnamed). % 29 
has_exit(35,unnamed). % 41

has_exit(36,7).
has_exit(36,16).
has_exit(36,unnamed).
has_exit(36,unnamed).

has_exit(37,10).
has_exit(37,15).
has_exit(37,20).
has_exit(37,42).

has_exit(38,22).
has_exit(38,40).
has_exit(38,43).
has_exit(38,unnamed). % 26
has_exit(38,unnamed). % 41

has_exit(39,4).
has_exit(39,11).
has_exit(39,12).

has_exit(40,6).
has_exit(40,11).
has_exit(40,38).
has_exit(40,unnamed). % 29

has_exit(41,1).
has_exit(41,10).
has_exit(41,35).
has_exit(41,38).

has_exit(42,4).
has_exit(42,22).
has_exit(42,25).
has_exit(42,30).
has_exit(42,27).

has_exit(43,22).
has_exit(43,38).
has_exit(43,unnamed). % 4
has_exit(43,unnamed). % 5 
has_exit(43,unnamed). % 14 
has_exit(43,unnamed). % 28

has_exit(44,21).
has_exit(44,18).
has_exit(44,unnamed). % 4
has_exit(44,unnamed). % 31

has_exit(45,17).
has_exit(45,19).
has_exit(45,23).
has_exit(45,28).
has_exit(45,36).


% Ein Raum ist eine Falle, wenn er nur Eingänge und keine Ausgänge hat.
% known_room/1 stellt sicher, dass nur nummerierte Räume geprüft werden
% (unnamed ist kein Raum im Sinne des Labyrinths).
% Negation als Fehlschlag (Negation as Failure, Closed World Assumption):
% Wenn has_exit(Room, _) nicht beweisbar ist, gilt der Raum als Falle.
% \+ bedeutet nicht "ist falsch", sondern "nicht beweisbar".
% Beispiel: Raum 24 ist eine Falle (http://www.intotheabyss.net/room-24/).
% is_trap(+Room) is semidet.
is_trap(Room) :-
    known_room(Room),
    \+ has_exit(Room, _).

% Eine Passage ist eine bidirektionale Verbindung zwischen zwei Räumen.
% Beispiel: ?- is_passage(1, 20).   % true, da 1->20 und 20->1 existieren
% Beispiel: ?- is_passage(1, 41).   % true
% is_passage(+From, +To) is semidet.
is_passage(From, To) :- 
    known_room(From), 
    known_room(To), 
    has_exit(From, To), 
    has_exit(To, From).

% Prüft ob ein Pfad von From nach To existiert. Unnamed exits werden ignoriert.
% Beispiel: ?- is_path(1, 45).   % true oder false
% Beispiel: ?- is_path(45, 1).   % true oder false
% is_path(+From, +To) is semidet.
is_path(From, To) :-
    is_path_(From, To, [From]).

% Interne Hilfsvariante mit Besuchten-Akkumulator gegen Zyklen.
% is_path_(+From, +To, @Visited) is semidet.
is_path_(From, To, _) :-
    has_exit(From, To),
    known_room(To).
is_path_(From, To, Visited) :-
    has_exit(From, Next),
    known_room(Next),
    \+ member(Next, Visited),
    is_path_(Next, To, [Next|Visited]).

% Liefert per Backtracking alle möglichen Pfade von From nach To als Liste.
% Beispiel: ?- find_paths(1, 45, Path).
% Beispiel: ?- findall(P, find_paths(1, 45, P), All).
% find_paths(+From, +To, -Path) is nondet.
find_paths(From, To, Path) :-
    find_paths_(From, To, [From], Path).

% Interne Hilfsvariante mit Besuchten-Akkumulator gegen Zyklen.
% find_paths_(+From, +To, @Visited, -Path) is nondet.
find_paths_(From, To, Visited, Path) :-
    has_exit(From, To),
    known_room(To),
    \+ member(To, Visited),
    reverse([To|Visited], Path).

find_paths_(From, To, Visited, Path) :-
    has_exit(From, Next),
    known_room(Next),
    \+ member(Next, Visited),
    find_paths_(Next, To, [Next|Visited], Path).


% Zählt wie viele unnamed exits ein Raum hat (nützlich zur Analyse).
% Beispiel: ?- count_unnamed(11, N).   % N = 4
% count_unnamed(+Room, -N) is det.
count_unnamed(Room, N) :-
    findall(_, has_exit(Room, unnamed), L),
    length(L, N).

% Findet Kandidaten für unbenannte Ausgänge eines Raums.
% Ein Kandidat X ist ein Raum, der einen benannten Eingang nach Room hat,
% für den Room aber noch keinen benannten Ausgang besitzt.
% Die Heuristik nutzt aus, dass fehlende Richtungen in Passagen die unnamed-Exits erklären.
% Beispiel: ?- unnamed_candidate(4, C).   % C = 39 ; C = 42
% unnamed_candidate(+Room, -Candidate) is nondet.
unnamed_candidate(Room, Candidate) :-
    known_room(Room),
    known_room(Candidate),
    has_exit(Candidate, Room),
    \+ has_exit(Room, Candidate).

% Zeigt für alle Räume mit unnamed-Ausgängen die Kandidaten an.
% Die Anzahl der Kandidaten sollte mit count_unnamed übereinstimmen.
% Beispiel: ?- show_unnamed_candidates.
% show_unnamed_candidates is det.
show_unnamed_candidates :-
    known_room(Room),
    count_unnamed(Room, N),
    N > 0,
    findall(C, unnamed_candidate(Room, C), Candidates),
    format("Raum ~w: ~w unnamed -> Kandidaten: ~w~n", [Room, N, Candidates]),
    fail.
show_unnamed_candidates.

% Findet den kürzesten Pfad von From nach To.
% setof/3 sortiert alle Pfade aufsteigend nach Länge,
% der Kopf der sortierten Liste ist der kürzeste.
% Schlägt fehl, wenn kein Pfad existiert.
% Beispiel: ?- shortest_path(1, 45, Path).
% Beispiel: ?- shortest_path(45, 1, Path).
% shortest_path(+From, +To, -Shortest) is semidet.
shortest_path(From, To, Shortest) :-
    setof(_-P, find_paths_(From, To, [From], P), [_-Shortest|_]).

% Geheimgang aus MAZE (Christopher Manson, 1985):
% Rundweg 1 -> 45 -> 1, bei dem kein Zwischenraum doppelt besucht wird.
% Der gemeinsame Besuchten-Akkumulator verhindert Überschneidungen.
% Beispiel: ?- maze_roundtrip(There, Back, Total).
% maze_roundtrip(-There, -Back, -Total) is nondet.
maze_roundtrip(There, Back, Total) :-
    find_paths_(1, 45, [1], There),
    % Alle auf dem Hinweg besuchten Räume als Startsperre für den Rückweg
    find_paths_(45, 1, There, Back),
    length(There, LT),
    length(Back, LB),
    Total is LT + LB - 2.

% Beispiel: ?- shortest_roundtrip(There, Back, Total).
% shortest_roundtrip(-BestThere, -BestBack, -BestTotal) is semidet.
shortest_roundtrip(BestThere, BestBack, BestTotal) :-
    findall(Total-There-Back, maze_roundtrip(There, Back, Total), All),
    All \= [],
    msort(All, [BestTotal-BestThere-BestBack|_]).


% Zählt alle Ausgänge inklusive unbekannter (unnamed).
% total_doors(-N) is det.
total_doors(N) :-
    findall(_, has_exit(_, _), Exits),
    length(Exits, N).

% Zählt nur Ausgänge zu bekannten (nummerierten) Räumen.
% total_named_doors(-N) is det.
total_named_doors(N) :-
    findall(_, (has_exit(_, To), known_room(To)), Exits),
    length(Exits, N).

% Alle von From aus erreichbaren Räume (sortiert, ohne From selbst).
% reachable(+From, -Rooms) is det.
reachable(From, Rooms) :-
    setof(R, is_path_(From, R, [From]), Rooms).

% Anzahl benannter Ausgänge eines Raums.
% out_degree(+Room, -N) is det.
out_degree(Room, N) :-
    findall(_, (has_exit(Room, To), known_room(To)), L),
    length(L, N).

% Anzahl benannter Eingänge zu einem Raum.
% in_degree(+Room, -N) is det.
in_degree(Room, N) :-
    findall(_, (has_exit(From, Room), known_room(From)), L),
    length(L, N).

% Artikulationspunkte: Räume, deren Entfernen den Pfad 1→45 unterbricht.
% cut_rooms(-Rooms) is det.
cut_rooms(Rooms) :-
    findall(R, (known_room(R), R \= 1, R \= 45, \+ path_without(R)), Rooms).

path_without(Room) :-
    find_paths_(1, 45, [1], Path),
    \+ member(Room, Path).

% Übersicht über das gesamte Labyrinth.
% maze_summary is det.
maze_summary :-
    total_doors(Total),
    total_named_doors(Named),
    Unnamed is Total - Named,
    findall(R, (known_room(R), is_trap(R)), Traps),
    length(Traps, NTraps),
    setof(Room, has_exit(Room, unnamed), RoomsUn),
    length(RoomsUn, NRoomsUn),
    findall(_, is_passage(_, _), Passages),
    length(Passages, NPassages),
    cut_rooms(Cuts),
    format("=== MAZE-Labyrinth Übersicht ===~n", []),
    format("Räume:                 ~w (1–45)~n", [45]),
    format("Ausgänge gesamt:       ~w~n", [Total]),
    format("  Davon benannt:       ~w~n", [Named]),
    format("  Davon unnamed:       ~w~n", [Unnamed]),
    format("Räume mit unnamed:     ~w~n", [NRoomsUn]),
    format("Passagen (2-Richtung): ~w~n", [NPassages]),
    format("Fallen (nur Eingang):  ~w~n", [NTraps]),
    format("Artikulationspunkte:   ~w~n", [Cuts]).

% Steckbrief eines Raums.
% room_info(+Room) is det.
room_info(Room) :-
    known_room(Room),
    findall(To, has_exit(Room, To), Exits),
    findall(From, (has_exit(From, Room), known_room(From)), Entrances),
    findall(To, (has_exit(Room, To), has_exit(To, Room), known_room(To)), Passages),
    count_unnamed(Room, NUnnamed),
    (is_trap(Room) -> Trap = ja ; Trap = nein),
    out_degree(Room, Out),
    in_degree(Room, In),
    setof(C, unnamed_candidate(Room, C), Candidates),
    format("Raum ~w~n", [Room]),
    format("  Ausgänge:            ~w~n", [Exits]),
    format("  Davon unnamed:       ~w~n", [NUnnamed]),
    format("  Eingänge:            ~w~n", [Entrances]),
    format("  Passagen:            ~w~n", [Passages]),
    format("  Falle:               ~w~n", [Trap]),
    format("  Out-Degree:          ~w~n", [Out]),
    format("  In-Degree:           ~w~n", [In]),
    (Candidates == [] -> true ;
     format("  Unnamed-Kandidaten:  ~w~n", [Candidates])).

%----------------------------------------------------------------------------------%
% Pro/Contra-Listendarstellung (Übungsaufgabe):
%   + kompakter, atomare Änderung pro Raum, direkte Längenabfrage
%   - inverse Suche („welcher Raum führt zu X?“) erfordert member/2
%   - Backtracking über Ausgänge umständlicher
%   + Determinismus: has_exits(1, L) ist det, has_exit(1, To) ist nondet
%   - unnamed-Exits sind kein Sonderfall mehr (Atom vs. Integer)
% Studierende sollen eigene Abwägung formulieren.
%----------------------------------------------------------------------------------%

% Alternative Listendarstellung – has_exits/2 pro Raum statt mehrerer has_exit/2-Fakten:
has_exits(1, [20, 21, 26, 41]).
has_exits(2, [12, 22, 29]).
% usw. 
