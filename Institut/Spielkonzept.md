# Spielkonzept

## Setting
Ein scheinbar verlasssenes Labor an einem vernebelten Waldrand in einem unbekannten Land.
Es scheint vor vielen Jahren fluchtartig verlassen worden zu sein. 
Möbiliar wie aus den 1960ern, aber technisches Equipment wie aus der Zukunft.

## Startpunkt
play. -> title -> intro -> Init
Wir stehen im Eingang eines Labors. Die Sicherheitseinganstür ist verschlossen und wird 
auch noch von einem umgestürzten Baum versperrt. Es gibt keine Fenster.
Wie wir hier hingekommen sind, wissen wir nicht. Es scheint fast so als wären wir hier 
hin teleportiert worden. Wir müssen herausfinden, was passiert ist und wie wir hier rauskommen

## Spielende
Die Spielfigure wird durch das Metarätsel vor das Labor teleportiert, da es das Spiel durchschaut hat.

Metarätsel geköst -> ausgabe.txt->"drücke eine taste" -> Spiel neu starten? -> 1. Neues Spiel -> init 
                                                                            -> 2. Beenden -> Outro 

## Orte und Lage

    Vor dem Labor
    |      |
    |    Eingang - Korridor - Labor (verschlossen, ID Karte) - Steuerpult (Schaltet Geheimtür frei, Deduktiosnrätsel) 
    |      |
    |  [Archivtür] (verschlossen, Brecheisen)
    |      |
    |    Archiv 
    |      |
    |    Regal (Umgekehrtes Rätsel, gibt Geheimraum frei)
    |      |
    |  [Geheimgang] (verborgen, verschlossen)
    |      |
    | Geheimraum (dunkel)
    |      |
    |  Geheimfach (Akte)
    |      |
    |  Teleport (Metarätsel)
    |      |
    |  Vor dem Labor
    |      |
    --------

## Objekte und ihre Funktion

Objekt              Ort                             Rolle                       Rätsel
-----------------------------------------------------------------------------------------------------           
Akte                Geheimkammer (im Geheimfach)    Hinweis                     Metarätsel      
Brecheisen          Eingang                         Werkzeug                
Buch                Schreibtisch (Schublade)        Hinweis                     Regalmechanismus  
ID-Karte            Korridor                        Schlüssel                   Key-Lock Rätsel für Archiv
Regal               Archiv                          Tarnung                     Kombinatoikrätsel
Schreibtisch        Korridor                        Behälter                    Enthält das Buch
Steuerpult          Labor                           Schalter                    Deduktionsrätsel öffnet Geheimraum 
Taschenlampe        Labor (auf dem Steuerpult)      Schlüssel                   Sichtbarkeitsrätsel Geheimfach


- Labor Rätsel
    ID Karte muss im Inventar sein
    Verwende ID Karte mit Labortür
    Bei verwende Brechstange mit Labortür: Die Labortür ist zu stark für das Brecheisen
    Bei Verwendung aller anderen Gegenstände Dafault Text ausgebem "Du kannst A nicht mit der Tür verwenden" o.ä.
    Korridor Korridor/Labor frei

- Steuerpult Rätsel
    Kreisförmige Regler, die dass Sonnensystem abbilden als Symbole mit der Sonne in der Mitte
    und den acht Planeten als Regler drumherum. Die Gradzahlen müssen als ein String eingegeben werden, damit die Eingabe nicht zu kompliziert wird. Dann muss das Sonnensymbol in der Mitte gedrückt werden, damit die Tür aufgeht. Auch hier der Einfachheit halber geschieht das autmatisch.

    Die richtigen Winkel der Schaltefinden sich in der Notiz am Schaltpult.
    Lösung: "180 135 315 270 90 45 0 180"

    1,☿ (Merkur),Hälfte des Kreises (360/2),180°
    2,♀ (Venus),"3/4 von Merkurs Weg (180×0,75)",135°
    3,♁ (Erde),Opposition zu Venus (135+180),315°
    4,♂ (Mars),"Horizontale, links",270°
    5,♃ (Jupiter),"Horizontale, rechts",90°
    6,♄ (Saturn),Ein Achtel zu weit (360+45(mod360)),45°
    7,♅ (Uranus),Unbewegt (Ursprung),0°
    8 (Äußerst),♆ (Neptun),Linie mit 1 & 7,180°
    

- Archivrätsel
    Die Tür ist aus Holz und hängt durch irh alter eh schon schief
    Brecheisen muss im Inventar sein
    Verwende Brecheisen mit Tür
    Verbindung frei Korridor/Archiv frei

- Schreibtisch Rätsel:
    Untersuche Schreibtisch -> Ein kastiger Laborschreibtsuch. Er hat einen Schublade. -> Unterssuche Schublade -> in der Schublade liegt ein abgewetztes Buch -> nimm Buch. Wenn im Inventory, kann das Buch betrachtet werden. 
    Betrachte Buch -> Buch standardkurzbeschreibung. 
    Untersuche Buch -> Langtextausgabe mit den Hinweisen für das Regalrätsel

- Regal Rätsel:
    Die Reihenfolge ist im Buch verschlüsselt hinterlegt.

    Rangfolge italinische Farben im Kartenspiel
    Bastoni (Keule) -> Coppe (Kelch) -> Denari (Münze) -> Spade (Schwert)

    7:  Münze, 11: Schwert, 13: Kelch, 17: Keule

    codiert die Reihenfolge, so dass die Aktenordner mit entsprechenden Indizes 
    genau in der Reihenfolge 17, 13, 7, 11 entfernt werden müssen, um den 
    Geheimgang frei zu legen. Den Hinweis dass die Symbole aus dem italienische 
    Kartenspiel Scopa kommen, gibt der Hinweis "Der Besen bringt Ordnung ins Spiel"
    Wie kann man das als Befehl / Aktion umsetzen:

    Lösung
    entferne Akte 17
    entferen Akte 13
    entferen Akte  7
    entferen Akte 11
    Du hörste einen Mechanismus aufspringen und das Regal bewegt sich zur Seite

    Alle anderen falschen Reihenfolgen ergeben
    Stille. Es passiert nichts. Du stellst due Bücher wieder zurück.


- Geheimraum Licht Rätsel.
    Taschenlampe muss im Inventar sein
    Taschenlampe muss aktiviert werdem
    Enteckung des Geheimfachs im Boden
    Erst dann kann die Geheimakte aufgenommen werden.
    Das Aufnehmen der Akte verschliesst die Geheimtür.
    Betrachte Akte gibt den kurtext aus.
    Untersuche Akte gibt den Langtext aus

- Metarätsel
    Die Spielfigur muss verstehen, dass sie aus dem System heraustreten kann.
    Der Geheimraum 3 Texte für unterschiedliche Spielstadien
    geheimraum.txt -> Umsehen nach Bertreten ohne Taschenlampe
    geheimraum_beleuchtet.txt -> Umsehen nach Bertreten mit Taschenlampe
    geheimraum_meta.txt -> Umsehen nachdem die Akte gefunden wurde. Gibt Hinweis auf Metaebene

    Lösung: sage retract(position(ich, _)), assert(position(ich, aussen)).


